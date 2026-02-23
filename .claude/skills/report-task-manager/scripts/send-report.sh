#!/bin/bash
# Usage: send-report.sh <task_status> <message>
# task_status: done | blocked | wip
set -euo pipefail

TASK_STATUS="${1:?Usage: send-report.sh <task_status> <message>}"
MESSAGE="${2:?Usage: send-report.sh <task_status> <message>}"

WINDOW=$(tmux display-message -t "$TMUX_PANE" -p '#{window_name}')
SESSION=$(tmux display-message -t "$TMUX_PANE" -p '#{session_name}')

wq add --source task-report \
  --meta "{\"session_id\":\"${WINDOW}\",\"pane\":\"${SESSION}:${WINDOW}.0\",\"task_status\":\"${TASK_STATUS}\"}" \
  "${MESSAGE}"

echo "報告を送信しました"
