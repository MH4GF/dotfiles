---
description: タスク管理者への報告。タスク完了・ブロック時に `/report-task-manager 完了しました` で発動
allowed-tools: Bash(tmux *)
---

# report-task-manager

タスク管理者（`main:works` ウィンドウ）にメッセージを送信する。

## 手順

1. `$ARGUMENTS` と現在の作業コンテキスト（直近の作業内容、PR URL、ブロッカー等）から、タスク管理者が次のアクションを判断できる報告文を組み立てる
2. ウィンドウ名を取得
3. 報告を送信（返信先アドレスはウィンドウ名から `main:<WINDOW>.0` で構成）

IMPORTANT: 情報取得と送信は**独立したBash呼び出し**で行う。1回にまとめない（コマンドが長くなり承認が必要になるため）。

IMPORTANT: `tmux send-keys` でテキストとEnterは必ず分離する。同時に送るとClaude Codeの入力欄でEnterが認識されないことがある。

```bash
# (1) ウィンドウ名取得（TMUX_PANEで自ペインを指定し、アクティブクライアント依存を回避）
tmux display-message -t "$TMUX_PANE" -p '#{window_name}'

# (2) テキスト送信（<WINDOW>を上の結果で置換）
tmux send-keys -t main:works '[<WINDOW> pane:main:<WINDOW>.0] <報告文>'
# (3) Enter送信（テキスト反映を待ってから）
sleep 1
tmux send-keys -t main:works Enter
```

### 報告文に含めるべき情報

- **状態**: done / blocked / wip
- **要点**: 何が完了した / 何にブロックされている
- **URL**: PR URL等があれば付与
- **次のアクション**: タスク管理者に判断を求める場合は明記

IMPORTANT: `$ARGUMENTS` が空の場合は `AskUserQuestion` で報告内容を確認する。
