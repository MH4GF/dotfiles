#!/bin/bash
# Usage: send-report.sh <task_status> <message>
# task_status: done | blocked | wip
set -euo pipefail

TASK_STATUS="${1:?Usage: send-report.sh <task_status> <message>}"
MESSAGE="${2:?Usage: send-report.sh <task_status> <message>}"

WINDOW=$(tmux display-message -t "$TMUX_PANE" -p '#{window_name}')
SESSION=$(tmux display-message -t "$TMUX_PANE" -p '#{session_name}')
TIMESTAMP=$(date '+%Y%m%dT%H%M%S')
CREATED_AT=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

QUEUE_DIR="${HOME}/.claude/report-queue/pending"
mkdir -p "$QUEUE_DIR"

cat > "${QUEUE_DIR}/${TIMESTAMP}-${RANDOM}-${WINDOW}.json" << EOF
{
  "session_id": "${WINDOW}",
  "pane": "${SESSION}:${WINDOW}.0",
  "task_status": "${TASK_STATUS}",
  "message": "${MESSAGE}",
  "created_at": "${CREATED_AT}"
}
EOF

echo "報告を送信しました: ${QUEUE_DIR}/${TIMESTAMP}-*-${WINDOW}.json"
