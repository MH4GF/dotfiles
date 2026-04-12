#!/bin/bash
set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/bin:/bin"

# ~/.claude/logs/*.jsonl のうち mtime > 14 日のファイルを削除する。
# 手動実行または cron で回す。aggregate-hook-logs.sh とは独立。

LOG_DIR="${CLAUDE_LOG_DIR:-${HOME}/.claude/logs}"
DAYS="${1:-14}"

if [ ! -d "$LOG_DIR" ]; then
  echo "rotate-hook-logs: $LOG_DIR does not exist, nothing to do" >&2
  exit 0
fi

find "$LOG_DIR" -name '*.jsonl' -type f -mtime "+${DAYS}" -print -delete
