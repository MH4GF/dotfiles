#!/bin/bash
set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

# worktree セッションが main ディレクトリのパスを参照するのを防ぐ。
# cwd が .claude/worktrees/ 配下の場合のみ発動し、
# ツール入力に main repo の絶対パスが含まれていたら deny する。
# deny 時は main_repo → cwd に置換した修正済みパスを提案する。

input=$(cat)
[[ "${WORKTREE_GUARD:-}" == "off" ]] && exit 0
cwd=$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null) || exit 0
[[ "$cwd" == *"/.claude/worktrees/"* ]] || exit 0

main_repo="${cwd%%/.claude/worktrees/*}"

tool_name=$(jq -r '.tool_name // empty' <<<"$input" 2>/dev/null) || exit 0

case "$tool_name" in
  Bash)
    target=$(jq -r '.tool_input.command // empty' <<<"$input" 2>/dev/null) ;;
  Read|Edit|Write|MultiEdit|NotebookEdit)
    target=$(jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' <<<"$input" 2>/dev/null) ;;
  Glob|Grep)
    target=$(jq -r '.tool_input.path // empty' <<<"$input" 2>/dev/null) ;;
  *)
    exit 0 ;;
esac

[ -z "$target" ] && exit 0

# 共有パスは main repo 側にあっても正当なアクセスなので除外
case "$target" in
  */.claude/plans/*|*/.claude/settings.json|*/.claude/settings.local.json) exit 0 ;;
esac

# main repo パスを含むが worktree パスは含まない → main を参照している
# $main_repo の後に / , 空白, 文字列末尾が来るケースのみマッチ（tq-utils 等の誤検出を防ぐ）
escaped_main=$(printf '%s' "$main_repo" | sed 's/[.[\*^$()+?{|\\]/\\&/g')
if echo "$target" | grep -qE "${escaped_main}(/|[[:space:]]|$)" && ! echo "$target" | grep -qF "$cwd"; then
  # 修正済みパスを提案: main_repo 部分を cwd に置換
  corrected="${target//$main_repo/$cwd}"
  cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"worktree内セッションがmainディレクトリを参照しています。修正パス: $corrected"}}
EOF
fi

exit 0
