#!/bin/bash
# Stop hook: task-mgrセッションでのみ、未処理報告をフィードバック
# 報告がある場合はdecision:blockでClaudeの停止を防ぎ、報告内容をreasonで伝える

# stdinからJSON inputを読み取り
INPUT=$(cat)

# task-mgrセッション以外は即終了
SESSION=$(tmux display-message -t "${TMUX_PANE:-}" -p '#{session_name}' 2>/dev/null)
[ "$SESSION" = "task-mgr" ] || exit 0

# 無限ループ防止: stop_hook_activeがtrueなら即終了
# （Claudeが報告処理→停止→hook再発火時にtrueになる）
STOP_HOOK_ACTIVE=$(printf '%s' "$INPUT" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("stop_hook_active",""))' 2>/dev/null)
[ "$STOP_HOOK_ACTIVE" = "True" ] && exit 0

QUEUE_DIR="${HOME}/.claude/report-queue/pending"
[ -d "$QUEUE_DIR" ] || exit 0

# pending報告を収集
REPORTS=""
COUNT=0
for f in "$QUEUE_DIR"/*.json; do
  [ -f "$f" ] || continue
  COUNT=$((COUNT + 1))
  REPORTS="${REPORTS}--- $(basename "$f") ---
$(cat "$f")

"
done

[ "$COUNT" -eq 0 ] && exit 0

# decision:blockでClaudeの停止を防ぎ、報告内容をreasonで伝える
REASON="サブセッションからの未処理報告が${COUNT}件あります。内容を確認し、適切に対応してください。

${REPORTS}処理完了後: mv ~/.claude/report-queue/pending/<file> ~/.claude/report-queue/done/"

# JSONエスケープ（改行・ダブルクォート・バックスラッシュ）
REASON_ESCAPED=$(printf '%s' "$REASON" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')

printf '{"decision":"block","reason":%s}' "$REASON_ESCAPED"
