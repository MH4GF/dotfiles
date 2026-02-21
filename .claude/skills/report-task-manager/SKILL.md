---
description: タスク管理者への報告。タスク完了・ブロック時に `/report-task-manager 完了しました` で発動
allowed-tools: Bash(*/send-report.sh *)
---

# report-task-manager

タスク管理者にJSONファイル経由で報告を送信する。報告は `~/.claude/report-queue/pending/` に書き込まれ、タスク管理者のStop hookが自動検知する。

## 手順

1. task_statusとmessageを決定（下記「推論ルール」参照）
2. `scripts/send-report.sh` を実行

```bash
~/.claude/skills/report-task-manager/scripts/send-report.sh <task_status> '<message>'
```

### task_status

- `done`: タスク完了
- `blocked`: ブロッカーあり、タスク管理者の判断が必要
- `wip`: 進捗報告（作業継続中）

### message に含めるべき情報

- **要点**: 何が完了した / 何にブロックされている
- **URL**: PR URL等があれば付与
- **次のアクション**: タスク管理者に判断を求める場合は明記

## 推論ルール

`$ARGUMENTS` が指定されている場合はその内容に従う。

`$ARGUMENTS` が空の場合は、セッションの会話コンテキストから自動推論する:

1. 直近の作業内容・実行結果・発生したエラーを分析
2. task_statusを判定:
   - 依頼されたタスクが完了している → `done`
   - 未解決のエラー・判断待ちがある → `blocked`
   - 作業途中で中間報告が必要 → `wip`
3. messageを生成（要点・URL・次のアクションを含める）
