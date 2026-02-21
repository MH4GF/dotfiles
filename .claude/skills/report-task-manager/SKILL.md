---
description: タスク管理者への報告。タスク完了・ブロック時に `/report-task-manager 完了しました` で発動
allowed-tools: Bash(*/send-report.sh *)
---

# report-task-manager

タスク管理者にJSONファイル経由で報告を送信する。報告は `~/.claude/report-queue/pending/` に書き込まれ、タスク管理者のStop hookが自動検知する。

## 手順

1. `$ARGUMENTS` と現在の作業コンテキストから、task_statusとmessageを決定
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

IMPORTANT: `$ARGUMENTS` が空の場合は `AskUserQuestion` で報告内容を確認する。
