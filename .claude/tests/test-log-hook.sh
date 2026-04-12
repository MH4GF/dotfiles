#!/bin/bash
set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

# Claude Code hook logger のオフライン単体テスト。
# $HOME / CLAUDE_LOG_DIR を throwaway dir に差し替えて、本物のログに触れない。

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOK="$SCRIPT_DIR/../hooks/log-hook-event.sh"

if [ ! -x "$HOOK" ]; then
  echo "FAIL: $HOOK not found or not executable"
  exit 1
fi

pass=0
fail=0

run_case() {
  local name=$1 payload=$2 jq_expr=$3 expected=$4
  local dir; dir=$(mktemp -d)
  echo "$payload" | CLAUDE_LOG_DIR="$dir" "$HOOK"
  local line; line=$(cat "$dir"/*.jsonl 2>/dev/null || true)
  rm -rf "$dir"
  if [ -z "$line" ]; then
    echo "FAIL $name: no log line written"
    fail=$((fail+1))
    return
  fi
  local got; got=$(jq -r "$jq_expr" <<<"$line")
  if [ "$got" = "$expected" ]; then
    echo "PASS $name"
    pass=$((pass+1))
  else
    echo "FAIL $name: got='$got' want='$expected'"
    fail=$((fail+1))
  fi
}

# 1. basic PreToolUse
run_case "basic PreToolUse event" \
  '{"session_id":"s1","hook_event_name":"PreToolUse","tool_name":"Bash","cwd":"/tmp","permission_mode":"default","tool_input":{"command":"ls"}}' \
  '.event' 'PreToolUse'

run_case "PreToolUse is_error is null" \
  '{"session_id":"s1","hook_event_name":"PreToolUse","tool_name":"Bash","cwd":"/tmp","permission_mode":"default","tool_input":{"command":"ls"}}' \
  '.is_error' 'null'

# 2. 長文字列トランケート (2048 + "…[truncated]"(12 char) = 2060)
big=$(python3 -c 'print("a"*3000, end="")')
run_case "truncate long command" \
  "{\"session_id\":\"s2\",\"hook_event_name\":\"PreToolUse\",\"tool_name\":\"Bash\",\"cwd\":\"/tmp\",\"permission_mode\":\"default\",\"tool_input\":{\"command\":\"$big\"}}" \
  '.tool_input.command | length' '2060'

# 3. session_id 欠落
run_case "missing session_id falls back to unknown" \
  '{"hook_event_name":"PermissionDenied","tool_name":"Bash","cwd":"/tmp","permission_mode":"default","tool_input":{"command":"rm"}}' \
  '.session_id' 'unknown'

# 4. PostToolUse で is_error=true を抽出 + tool_response 本文を捨てる
run_case "PostToolUse is_error extracted" \
  '{"session_id":"s3","hook_event_name":"PostToolUse","tool_name":"Bash","cwd":"/tmp","permission_mode":"default","tool_input":{"command":"x"},"tool_response":{"is_error":true,"stdout":"LARGE STDOUT SHOULD NOT APPEAR"}}' \
  '.is_error' 'true'

run_case "tool_response body dropped" \
  '{"session_id":"s3","hook_event_name":"PostToolUse","tool_name":"Bash","cwd":"/tmp","permission_mode":"default","tool_input":{"command":"x"},"tool_response":{"is_error":true,"stdout":"LARGE STDOUT SHOULD NOT APPEAR"}}' \
  '.tool_response // "absent"' 'absent'

# 5. PostToolUse で is_error 未指定 → false
run_case "PostToolUse is_error default false" \
  '{"session_id":"s4","hook_event_name":"PostToolUse","tool_name":"Bash","cwd":"/tmp","permission_mode":"default","tool_input":{"command":"x"},"tool_response":{}}' \
  '.is_error' 'false'

# 6. tool_use_id passthrough
run_case "tool_use_id passthrough" \
  '{"session_id":"s5","hook_event_name":"PreToolUse","tool_use_id":"toolu_01abc","tool_name":"Bash","cwd":"/tmp","permission_mode":"default","tool_input":{"command":"x"}}' \
  '.tool_use_id' 'toolu_01abc'

run_case "tool_use_id null fallback" \
  '{"session_id":"s5","hook_event_name":"PreToolUse","tool_name":"Bash","cwd":"/tmp","permission_mode":"default","tool_input":{"command":"x"}}' \
  '.tool_use_id' 'null'

echo
echo "Results: PASS=$pass FAIL=$fail"
if [ $fail -gt 0 ]; then
  exit 1
fi
echo "ALL PASS"
