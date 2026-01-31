---
name: session-log
description: Show the current session's log file path
allowed-tools:
  - Bash(~/.claude/skills/session-log/scripts/get-log-path.sh *)
---

Session log path:
!`~/.claude/skills/session-log/scripts/get-log-path.sh ${CLAUDE_SESSION_ID}`

Output this path to the user.
