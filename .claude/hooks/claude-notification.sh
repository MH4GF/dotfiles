#!/bin/bash
set -euo pipefail

INPUT=$(cat)

notification_type=$(echo "$INPUT" | jq -r '.notification_type // "stop"')
cwd=$(echo "$INPUT" | jq -r '.cwd // empty')
project_name=$(basename "${cwd:-${PWD:-unknown}}")

DELAY_SECONDS=300
SESSION_ID="${TMUX_PANE:-default}"
SESSION_ID="${SESSION_ID//[^a-zA-Z0-9]/_}"
PENDING_FILE="/tmp/claude-notification-pending-${SESSION_ID}"

cancel_pending() {
  if [ -f "$PENDING_FILE" ]; then
    local pid
    pid=$(cat "$PENDING_FILE" 2>/dev/null || echo "")
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      pkill -P "$pid" 2>/dev/null || true
      kill "$pid" 2>/dev/null || true
    fi
    rm -f "$PENDING_FILE"
  fi
}

case "$notification_type" in
  permission_prompt|tool_permission_prompt)
    message="[$project_name] 権限の確認が必要です"
    ;;
  user_question_prompt)
    message="[$project_name] 質問があります"
    ;;
  idle_prompt|stop)
    cancel_pending
    exit 0
    ;;
  *)
    message="[$project_name] 確認が必要です"
    ;;
esac

cancel_pending

(
  sleep "$DELAY_SECONDS"
  wq add --source "claude-notification" --meta "{\"project\":\"$project_name\",\"type\":\"$notification_type\"}" "$message"
  rm -f "$PENDING_FILE"
) &

echo $! > "$PENDING_FILE"
