---
description: Git worktree作成・管理。「worktree作って」「ブランチ用のworktree」で発動
allowed-tools: Bash(wtp *)
argument-hint: <task-description>
---

# wtp (Worktree Plus)

Git worktreeの作成・一覧・削除を行う。

## コマンドリファレンス

```bash
wtp add -b <new-branch>           # 新規ブランチでworktree作成
wtp add <existing-branch>         # 既存ブランチのworktree作成
wtp add -b <new-branch> <commit>  # 特定コミットから作成
wtp ls                            # 一覧
wtp rm <name>                     # 削除
wtp cd <name>                     # パス出力
```

## 動作

1. `$ARGUMENTS` またはコンテキスト（タスク内容、Issue等）からブランチ名を自動生成する
   - 形式: `kebab-case`、英語、短く（例: `fix-login-redirect`, `add-user-avatar`）
   - タスクの本質を表す動詞+名詞（`fix-*`, `add-*`, `refactor-*`, `update-*`）
2. `wtp add -b <generated-branch>` を実行
3. 作成後、`wtp cd <name>` でworktreeの絶対パスを取得して報告
