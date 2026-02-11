#!/bin/bash
set -euo pipefail

global_settings="$HOME/.claude/settings.json"
ghq_root="$(ghq root)"
found_repos=0

# Collect all local allow entries
all_local=$(
  for repo in $(ghq list); do
    file="$ghq_root/$repo/.claude/settings.local.json"
    [ -f "$file" ] || continue
    entries=$(jq -r '.permissions.allow // [] | .[]' "$file" 2>/dev/null) || continue
    if [ -n "$entries" ]; then
      found_repos=$((found_repos + 1))
      echo "$entries"
    fi
  done | sort -u
)

# Get global allow/deny/ask
global_allow=$(jq -r '.permissions.allow // [] | .[]' "$global_settings" | sort -u)
global_deny=$(jq -r '.permissions.deny // [] | .[]' "$global_settings" | sort -u)
global_ask=$(jq -r '.permissions.ask // [] | .[]' "$global_settings" | sort -u)
global_all=$(printf '%s\n%s\n%s' "$global_allow" "$global_deny" "$global_ask" | sort -u)

# New entries = local - global
new_entries=$(comm -23 <(echo "$all_local") <(echo "$global_all"))

# Filter: only valid permission patterns
filtered=$(echo "$new_entries" | grep -E '^(Bash\(|WebFetch\(|Skill\(|mcp__|Read\(|Write\(|Edit\(|Grep|Glob|SlashCommand)' || true)

# Exclude session-specific noise
filtered=$(echo "$filtered" | grep -vE '(git commit -m|Co-Authored-By|__NEW_LINE_|EVENT=)' || true)
filtered=$(echo "$filtered" | grep -vE '^Bash\((do|done|while read|for .* in |\[ -f )' || true)
filtered=$(echo "$filtered" | grep -vE '^Bash\(do ' || true)
filtered=$(echo "$filtered" | grep -vE '(EOF|\\)")' || true)
filtered=$(echo "$filtered" | grep -vE '^Bash\((DATE|AWS_PROFILE)=' || true)

# Exclude project-specific
filtered=$(echo "$filtered" | grep -vE '^Bash\((\./|/Users/|/opt/)' || true)
filtered=$(echo "$filtered" | grep -vE '^Bash\(export PATH=' || true)
filtered=$(echo "$filtered" | grep -vE '^Bash\(pnpm --filter ' || true)

# Exclude globally unsafe git operations
filtered=$(echo "$filtered" | grep -vE '^Bash\(git (reset|checkout|commit):' || true)

# Exclude entries subsumed by global wildcards
while IFS= read -r candidate; do
  [ -z "$candidate" ] && continue
  subsumed=false

  # Extract command prefix for Bash entries: Bash(cmd:*) -> "cmd"
  if [[ "$candidate" =~ ^Bash\((.+)\)$ ]]; then
    candidate_cmd="${BASH_REMATCH[1]}"
    candidate_cmd="${candidate_cmd%:*}"  # Remove trailing :*
    candidate_cmd="${candidate_cmd% *}"  # Remove arguments for exact match

    while IFS= read -r global_entry; do
      if [[ "$global_entry" =~ ^Bash\((.+):\*\)$ ]]; then
        global_prefix="${BASH_REMATCH[1]}"
        if [[ "$candidate_cmd" == "$global_prefix"* ]]; then
          subsumed=true
          break
        fi
      fi
    done <<< "$global_allow"
  fi

  $subsumed || echo "$candidate"
done <<< "$filtered" | sort -u
