#!/bin/bash
set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

# aggregate-hook-logs.sh のスモークテスト。
# 検証するのは grouping と ask_flow の導出、cross-reference フラグまで。
# 判定・分類 (script 抽出候補か、deny 候補か、等) は /analyze-hook-logs 側の
# 責務なのでここではテストしない。

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGG="$SCRIPT_DIR/../bin/aggregate-hook-logs.sh"
FIXTURE="$SCRIPT_DIR/fixtures/sample-logs.jsonl"
SETTINGS="$SCRIPT_DIR/../settings.json"

if [ ! -x "$AGG" ]; then echo "FAIL: $AGG not executable"; exit 1; fi
if [ ! -f "$FIXTURE" ]; then echo "FAIL: $FIXTURE missing"; exit 1; fi

dir=$(mktemp -d)
trap 'rm -rf "$dir"' EXIT
cp "$FIXTURE" "$dir/fixture.jsonl"

output=$(CLAUDE_LOG_DIR="$dir" CLAUDE_SETTINGS="$SETTINGS" bash "$AGG" --since 30 --format json)

assert_jq() {
  local name=$1 expr=$2
  if echo "$output" | jq -e "$expr" >/dev/null 2>&1; then
    echo "PASS $name"
  else
    echo "FAIL $name: $expr"
    echo "--- raw output ---"
    echo "$output" | jq .
    exit 1
  fi
}

# --- 基本構造 ---
assert_jq "period 存在"                 '.period.since_days == 30'
assert_jq "stats.total_events > 0"      '.stats.total_events > 0'
assert_jq "stats.total_invocations > 0" '.stats.total_invocations > 0'
assert_jq "current_settings 存在"       '.current_settings.allow_bash_prefixes | length > 0'
assert_jq "groups 存在"                 '.groups | length >= 1'

# --- invocation aggregation の正しさ ---
# 同じ session の PreToolUse + PermissionRequest + PostToolUse は 1 invocation に集約されるべき
# fixture: s1 の pnpm test --filter foo は 3 event → 1 invocation
# 合計: 10 session = 10 invocations
assert_jq "10 sessions → 10 invocations" '.stats.total_invocations == 10'
assert_jq "session 数一致"               '.stats.sessions == 10'

# --- ask_flow 導出 ---
# s1-s7 (ask→allow): user_allowed 7
# s8 (auto 実行): auto_allowed 1
# s9, s10 (auto 実行): auto_allowed 2
# 合計: user_allowed=7, auto_allowed=3
assert_jq "by_ask_flow.user_allowed == 7" '.stats.by_ask_flow.user_allowed == 7'
assert_jq "by_ask_flow.auto_allowed == 3" '.stats.by_ask_flow.auto_allowed == 3'

# --- grouping ---
# pnpm test --filter {foo,bar,baz} は 3 session 異なるが cmd_prefix "pnpm test" で 1 group 化される
assert_jq "pnpm test グループ count=3" \
  '.groups | any(.cmd_prefix == "pnpm test" and .count == 3)'

# cwd 分布 (project-specific 判定用に Claude が使う)
assert_jq "pnpm test の cwds が /repo/a に集中" \
  '.groups | any(.cmd_prefix == "pnpm test" and (.cwds[0].path == "/repo/a"))'

# ask_flow_breakdown per group
assert_jq "pnpm test の user_allowed == 3" \
  '.groups | any(.cmd_prefix == "pnpm test" and .ask_flow_breakdown.user_allowed == 3)'

# --- cross-reference フラグ ---
# gh pr merge は現 settings.json の permissions.ask に入っているので in_current_ask=true
assert_jq "gh pr グループ in_current_ask=true" \
  '.groups | any(.cmd_prefix == "gh pr" and .in_current_ask == true)'

# --- permission_mode の保持 ---
# vim config.yml は plan mode で実行された
assert_jq "vim の permission_modes=[plan]" \
  '.groups | any(.head_token == "vim" and .permission_modes == ["plan"])'

# --- example_commands ---
# 長い one-liner の例が保持されている
assert_jq "for f グループが example_commands を持つ" \
  '.groups | any(.cmd_prefix == "for f" and (.example_commands | length >= 1))'

# --- error_count ---
# ls /tmp と ls /nonexistent は is_error=true で記録されている
assert_jq "ls のエラー合計が 2 以上" \
  '[.groups[] | select(.head_token == "ls") | .error_count] | add >= 2'

# --- rm -rf グループが存在する (Claude が分類判断するのに必要) ---
assert_jq "rm -rf グループが存在" \
  '.groups | any(.cmd_prefix == "rm -rf")'

echo
echo "ALL PASS"
