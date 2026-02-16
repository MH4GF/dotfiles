#!/bin/bash
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

SESSION_NAME="${1:-}"
PANE_ID="${2:-}"
TMUX_SOCKET="${3:-}"

if [ -z "$SESSION_NAME" ] || [ -z "$PANE_ID" ] || [ -z "$TMUX_SOCKET" ]; then
  exit 1
fi

TMUX_CMD="tmux -S $TMUX_SOCKET"

window_id=$($TMUX_CMD display-message -t "$PANE_ID" -p '#{window_id}' 2>/dev/null) || exit 0
$TMUX_CMD select-window -t "$window_id" 2>/dev/null || true
$TMUX_CMD select-pane -t "$PANE_ID" 2>/dev/null || true

osascript -e 'tell application "iTerm2" to activate' 2>/dev/null || true
