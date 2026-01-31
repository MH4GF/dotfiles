#!/bin/bash
session_id="$1"
encoded=$(pwd | sed 's|/|-|g' | sed 's|\.|-|g')
echo ~/.claude/projects/${encoded}/${session_id}.jsonl
