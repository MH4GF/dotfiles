#!/bin/bash
set -euo pipefail

ghq_root="$(ghq root)"
total_cleaned=0

for repo in $(ghq list); do
  dir="$ghq_root/$repo"
  [ -d "$dir/.git" ] || continue

  cd "$dir"
  git fetch --prune 2>/dev/null || continue

  gone_branches=$(git branch -v 2>/dev/null | grep '\[gone\]' | sed 's/^[+* ]//' | awk '{print $1}' || true)
  [ -z "$gone_branches" ] && continue

  count=0
  while IFS= read -r branch; do
    worktree=$(git worktree list 2>/dev/null | grep "\\[$branch\\]" | awk '{print $1}' || true)
    if [ -n "$worktree" ] && [ "$worktree" != "$(git rev-parse --show-toplevel)" ]; then
      git worktree remove --force "$worktree" 2>/dev/null && echo "  worktree removed: $worktree"
    fi
    git branch -D "$branch" 2>/dev/null && echo "  branch deleted: $branch"
    count=$((count + 1))
  done <<< "$gone_branches"

  echo "$repo: ${count} branch(es) cleaned"
  total_cleaned=$((total_cleaned + count))
done

if [ "$total_cleaned" -eq 0 ]; then
  echo "No [gone] branches found across all repositories. Nothing to clean up."
fi
