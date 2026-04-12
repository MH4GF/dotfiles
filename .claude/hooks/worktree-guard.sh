#!/bin/bash
set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

# worktree セッションが main ディレクトリのパスを参照するのを防ぐ。
# cwd が .claude/worktrees/ 配下の場合のみ発動し、
# ツール入力に main repo の絶対パスが含まれていたら deny する。

input=$(cat)
cwd=$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null) || exit 0
[[ "$cwd" == *"/.claude/worktrees/"* ]] || exit 0

main_repo="${cwd%%/.claude/worktrees/*}"

tool_name=$(jq -r '.tool_name // empty' <<<"$input" 2>/dev/null) || exit 0

case "$tool_name" in
  Bash)
    target=$(jq -r '.tool_input.command // empty' <<<"$input" 2>/dev/null) ;;
  Read|Edit|Write|MultiEdit)
    target=$(jq -r '.tool_input.file_path // empty' <<<"$input" 2>/dev/null) ;;
  Glob|Grep)
    target=$(jq -r '.tool_input.path // empty' <<<"$input" 2>/dev/null) ;;
  *)
    exit 0 ;;
esac

[ -z "$target" ] && exit 0

# plan ファイルは main repo や別 worktree 側に保存される場合があるため除外
echo "$target" | grep -qF "/.claude/plans/" && exit 0

# main repo パスを含むが worktree パスは含まない → main を参照している
if echo "$target" | grep -qF "$main_repo/" && ! echo "$target" | grep -qF "$cwd"; then
  cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"worktree内のセッションですがmainディレクトリを参照しています。相対パスまたはworktreeのパスを使用してください: $cwd"}}
EOF
fi

exit 0
