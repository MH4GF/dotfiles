#!/bin/bash
set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

# Claude Code の 4 hook イベント (PreToolUse / PostToolUse / PermissionRequest /
# PermissionDenied) を JSONL で ~/.claude/logs/<session_id>.jsonl に追記する。
# stdout には一切出さない — harness が判定として誤解釈するのを防ぐため。
# どんな失敗でも tool 呼び出しをブロックせず exit 0 で抜ける。

LOG_DIR="${CLAUDE_LOG_DIR:-${HOME}/.claude/logs}"
mkdir -p "$LOG_DIR"

input=$(cat)
session_id=$(jq -r '.session_id // "unknown"' <<<"$input" 2>/dev/null || echo "unknown")
log_file="${LOG_DIR}/${session_id}.jsonl"

# jq builtin walk() で tool_input 内の長文字列を 2048 char で切り詰める。
# tool_response 本文は保存せず、is_error フラグのみ抽出（secrets & size 対策）。
jq -c --argjson max 2048 '
  def trunc: if type == "string" and (length > $max)
             then (.[0:$max] + "…[truncated]") else . end;
  {
    ts: (now | todateiso8601),
    event: .hook_event_name,
    session_id: (.session_id // "unknown"),
    tool_use_id: (.tool_use_id // null),
    tool_name: .tool_name,
    cwd: .cwd,
    permission_mode: .permission_mode,
    tool_input: (.tool_input | walk(trunc)),
    is_error: (
      if .hook_event_name == "PostToolUse"
      then (.tool_response.is_error // .tool_response.interrupted // false)
      else null
      end
    )
  }
' <<<"$input" >>"$log_file" 2>/dev/null || true

exit 0
