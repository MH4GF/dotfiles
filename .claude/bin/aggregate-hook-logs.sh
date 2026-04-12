#!/bin/bash
set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

# Claude Code hook logs を集計し、invocation 単位の grouped data を出力する。
# **分類・判定は行わない** — /analyze-hook-logs (= Claude) が現行 settings や
# 例コマンドを読んで判断する。ここでは grouping と事実収集のみ。
#
# Usage: aggregate-hook-logs.sh [--since N] [--format json|md]
#
#   --since N      集計対象期間 (日数、デフォルト 14)
#   --format json  構造化 JSON (デフォルト、/analyze-hook-logs 用)
#   --format md    人間向け概要 markdown (top 20 グループの表)
#
# 環境変数:
#   CLAUDE_LOG_DIR   ログ格納ディレクトリ (デフォルト: ~/.claude/logs)
#   CLAUDE_SETTINGS  settings.json のパス (デフォルト: ~/.claude/settings.json)

SINCE=14
FORMAT=json

while [[ $# -gt 0 ]]; do
  case $1 in
    --since) SINCE=$2; shift 2 ;;
    --format) FORMAT=$2; shift 2 ;;
    -h|--help) sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

LOG_DIR="${CLAUDE_LOG_DIR:-${HOME}/.claude/logs}"
SETTINGS="${CLAUDE_SETTINGS:-${HOME}/.claude/settings.json}"

# cutoff (BSD / GNU date 両対応)
if cutoff=$(date -u -v-"${SINCE}"d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null); then
  :
else
  cutoff=$(date -u -d "${SINCE} days ago" +%Y-%m-%dT%H:%M:%SZ)
fi

# 現行 settings.json から Bash prefix を抽出
extract_prefixes() {
  local key=$1
  if [ -f "$SETTINGS" ]; then
    jq -c "[.permissions.${key}[]? | select(type==\"string\" and startswith(\"Bash(\")) | capture(\"^Bash\\\\((?<p>[^:)]+)\") | .p]" "$SETTINGS" 2>/dev/null || echo '[]'
  else
    echo '[]'
  fi
}
ALLOW_PREFIXES=$(extract_prefixes allow)
ASK_PREFIXES=$(extract_prefixes ask)
DENY_PREFIXES=$(extract_prefixes deny)

# ログを cutoff で絞り込んで tmp に書き出す
TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

if [ -d "$LOG_DIR" ] && compgen -G "${LOG_DIR}/*.jsonl" >/dev/null 2>&1; then
  cat "$LOG_DIR"/*.jsonl 2>/dev/null \
    | jq -c --arg cutoff "$cutoff" 'select(.ts >= $cutoff)' > "$TMP" || true
fi

# --- 分析本体 -----------------------------------------------------------
analysis=$(jq -s \
  --argjson allow_prefixes "$ALLOW_PREFIXES" \
  --argjson ask_prefixes "$ASK_PREFIXES" \
  --argjson deny_prefixes "$DENY_PREFIXES" \
  --arg since "$SINCE" \
  --arg cutoff "$cutoff" '

  def head_token: (. // "") | split(" ") | .[0] // "";
  def cmd_prefix: (. // "") | split(" ") | .[0:2] | join(" ");
  def matches_any($xs): . as $c | any($xs[]?; . as $p | $c | startswith($p));

  . as $all

  # --- Step 1: invocation aggregation ---
  # 同一 (session_id, tool_name, command) の Pre/Req/Denied/Post を 1 レコードにまとめ、
  # ask_flow を 4 状態で導出する (mechanical、判定ではない)
  | ($all
      | group_by([.session_id, .tool_name, (.tool_input.command // "")])
      | map({
          session_id:      .[0].session_id,
          tool_name:       .[0].tool_name,
          command:         (.[0].tool_input.command // ""),
          cwd:             .[0].cwd,
          permission_mode: .[0].permission_mode,
          first_ts:        ([.[] | .ts] | min),
          had_pre:         any(.[]; .event == "PreToolUse"),
          had_req:         any(.[]; .event == "PermissionRequest"),
          had_denied:      any(.[]; .event == "PermissionDenied"),
          had_post:        any(.[]; .event == "PostToolUse"),
          post_error:      any(.[]; .event == "PostToolUse" and .is_error == true)
        })
      | map(. + {
          ask_flow: (
            if .had_denied then "auto_denied"
            elif .had_req and .had_post then "user_allowed"
            elif .had_req and (.had_post | not) then "user_denied"
            elif .had_post then "auto_allowed"
            else "unknown"
            end
          )
        })
    ) as $inv

  # --- Step 2: group by (tool_name, cmd_prefix) ---
  | ($inv | group_by([.tool_name, (.command | cmd_prefix)])
          | map({
              tool_name:  .[0].tool_name,
              head_token: (.[0].command | head_token),
              cmd_prefix: (.[0].command | cmd_prefix),
              count:      length,
              ask_flow_breakdown: (
                [.[] | .ask_flow]
                | group_by(.)
                | map({key: .[0], value: length})
                | from_entries
              ),
              permission_modes: ([.[] | .permission_mode // "unknown"] | unique),
              cwds: (
                [.[] | .cwd // "unknown"]
                | group_by(.)
                | map({path: .[0], count: length})
                | sort_by(-.count)
                | .[0:5]
              ),
              example_commands: ([.[] | .command] | unique | .[0:5]),
              error_count: ([.[] | select(.post_error)] | length),
              first_seen: ([.[] | .first_ts] | min),
              last_seen:  ([.[] | .first_ts] | max),
              in_current_allow: (.[0].command | matches_any($allow_prefixes)),
              in_current_ask:   (.[0].command | matches_any($ask_prefixes)),
              in_current_deny:  (.[0].command | matches_any($deny_prefixes))
            })
          | sort_by(-.count)
    ) as $groups

  # --- Step 3: stats + 組み立て ---
  | {
      period: {
        since_days: ($since | tonumber),
        cutoff: $cutoff
      },
      stats: {
        total_events:      ($all | length),
        total_invocations: ($inv | length),
        sessions:          ($all | map(.session_id) | unique | length),
        by_tool: (
          $all | group_by(.tool_name // "unknown")
               | map({tool: (.[0].tool_name // "unknown"), count: length})
               | sort_by(-.count)
               | .[0:10]
        ),
        by_mode: (
          $all | group_by(.permission_mode // "unknown")
               | map({key: (.[0].permission_mode // "unknown"), value: length})
               | from_entries
        ),
        by_ask_flow: (
          $inv | group_by(.ask_flow)
               | map({key: .[0].ask_flow, value: length})
               | from_entries
        )
      },
      current_settings: {
        allow_bash_prefixes: $allow_prefixes,
        ask_bash_prefixes:   $ask_prefixes,
        deny_bash_prefixes:  $deny_prefixes
      },
      groups: $groups
    }
' "$TMP")

if [ "$FORMAT" = "json" ]; then
  echo "$analysis"
  exit 0
fi

# --- markdown 概要 (人間向け top 20) --------------------------------------
echo "$analysis" | jq -r '
  "# Claude Code hook logs 集計 (since \(.period.since_days) days)",
  "",
  "## 概要",
  "- セッション: \(.stats.sessions)",
  "- 総イベント: \(.stats.total_events)",
  "- 総 invocation: \(.stats.total_invocations)",
  "- ask_flow 内訳: \(.stats.by_ask_flow | tostring)",
  "- mode 内訳: \(.stats.by_mode | tostring)",
  "",
  "## Top 20 グループ (tool × cmd_prefix)",
  (.groups | .[0:20] | map(
    "- [\(.tool_name)] `\(.cmd_prefix)` × \(.count)"
    + " flow=\(.ask_flow_breakdown | tostring)"
    + " | allow=\(.in_current_allow) ask=\(.in_current_ask) deny=\(.in_current_deny)"
    + (if .error_count > 0 then " errors=\(.error_count)" else "" end)
  ) | join("\n")),
  "",
  "詳細は `--format json` / 改善提案は `/analyze-hook-logs` を使用"
'
