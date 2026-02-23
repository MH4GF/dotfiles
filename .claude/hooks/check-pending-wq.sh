#!/bin/bash
# Stop hook: task-mgrセッションでのみ、未処理のwork-queueアイテムをフィードバック
# アイテムがある場合はdecision:blockでClaudeの停止を防ぎ、内容をreasonで伝える

# stdinからJSON inputを読み取り
INPUT=$(cat)

# task-mgrセッション以外は即終了
SESSION=$(tmux display-message -t "${TMUX_PANE:-}" -p '#{session_name}' 2>/dev/null)
[ "$SESSION" = "task-mgr" ] || exit 0

# 無限ループ防止: stop_hook_activeがtrueなら即終了
STOP_HOOK_ACTIVE=$(printf '%s' "$INPUT" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("stop_hook_active",""))' 2>/dev/null)
[ "$STOP_HOOK_ACTIVE" = "True" ] && exit 0

WQ="$HOME/ghq/github.com/MH4GF/works/.claude/tools/wq/wq"

# wqが存在しなければ終了
[ -x "$WQ" ] || exit 0

PENDING=$("$WQ" list --status pending --limit 5 2>/dev/null)

# 出力が空ならpending無し
[ -z "$PENDING" ] && exit 0

REASON="未処理のwork-queueアイテムがあります。内容を確認し、適切に対応してください。

${PENDING}

処理完了後: wq done <id>"

# JSONエスケープ（改行・ダブルクォート・バックスラッシュ）
REASON_ESCAPED=$(printf '%s' "$REASON" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')

printf '{"decision":"block","reason":%s}' "$REASON_ESCAPED"
