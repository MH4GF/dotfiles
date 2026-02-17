#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INPUT=$(cat)

notification_type=$(echo "$INPUT" | jq -r '.notification_type // "stop"')
cwd=$(echo "$INPUT" | jq -r '.cwd // empty')
project_name=$(basename "${cwd:-unknown}")

case "$notification_type" in
  permission_prompt|tool_permission_prompt)
    title="Claude Code - Permission"
    message="[$project_name] 権限の確認が必要です"
    ;;
  user_question_prompt)
    title="Claude Code - Question"
    message="[$project_name] 質問があります"
    ;;
  idle_prompt|stop)
    exit 0
    ;;
  *)
    title="Claude Code"
    message="[$project_name] 確認が必要です"
    ;;
esac

execute_args=()
if [ -n "${TMUX_PANE:-}" ]; then
  session_name=$(tmux display-message -p '#{session_name}' 2>/dev/null || echo "")
  tmux_socket=$(echo "$TMUX" | cut -d, -f1)
  execute_args=(-execute "$SCRIPT_DIR/focus-tmux-pane.sh '$session_name' '$TMUX_PANE' '$tmux_socket'")
fi

nohup terminal-notifier \
  -title "$title" \
  -message "$message" \
  "${execute_args[@]}" \
  -activate com.googlecode.iterm2 \
  >/dev/null 2>&1 &
