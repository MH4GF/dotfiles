---
description: Watch GitHub notifications
mode: interactive
---
GitHub通知を取得・分類し、必要なタスク/アクションを作成する。

## 手順

### 1. 通知取得

```bash
gh api /notifications --paginate --jq '.[] | {id: .id, reason: .reason, subject_type: .subject.type, title: .subject.title, repo: .repository.full_name, subject_url: .subject.url}' 2>/dev/null
```

通知が0件なら「通知なし」と出力して終了。

### 2. 各通知の処理

各通知について以下を順に実行:

#### 2a. 詳細取得

subject_urlからrepo名と番号を抽出し、subject_typeに応じて取得:

- **PullRequest**: `gh pr view <number> --repo <owner/repo> --json url,state,author,headRefName,reviewDecision,mergeStateStatus,statusCheckRollup,isDraft`
- **Issue**: `gh issue view <number> --repo <owner/repo> --json url,state,author`
- **Discussion/Release**: `gh api`で取得

#### 2b. スキップ判定

以下は既読にしてスキップ:
- state が merged/closed
- Discussion/Release
- bot（dependabot, renovate, github-actions等）による自動更新通知

#### 2c. リモートアクションPR検出

headRefNameが `tq-<数字>-` にマッチする場合:
```bash
# 例: tq-42-fix-bug → action_id=42
tq action done <action_id> "remote:pr=<pr_url>"
```
既読にしてスキップ。

#### 2d. プロンプト選択

要対応の通知について、以下の優先順で**最初に該当する**プロンプトを選択:

| 優先 | 条件 | プロンプト |
|---|---|---|
| 1 | `mergeStateStatus: "BEHIND"` or conflicting | `fix-conflict` |
| 2 | statusCheckRollup に failure あり | `fix-ci` |
| 3 | `reviewDecision: "CHANGES_REQUESTED"` / 未対応レビューコメント | `respond-review` |
| 4 | `reviewDecision: "APPROVED"` + CI pass + mergeable | `merge-pr` |
| 5 | 自分のPRで未レビュー | `self-review` |
| 6 | その他の実装・修正依頼 | `implement` |

**選択不可**: `classify-gh-notification`, `classify-next-action`, `watch-gh-notifications`

#### 2e. 既存タスク照合

```bash
tq task list --status open
```

上から順に試行し、最初にヒットしたタスクを使う:

1. **URL一致**: 通知のURLが既存タスクのURLと完全一致
2. **タイトルキーワード一致**: 通知タイトルからキーワード（PR番号 `#123`、チケットID `PROJ-456`、リポジトリ名等）を抽出し、既存タスクのタイトルと照合
3. **該当なし**: 新規タスク作成（プロジェクト不明なら **works** に分類）

#### 2f. アクション作成

```bash
# 新規タスクが必要な場合
tq task create --project <project_name> --title "<title>" --url "<url>"

# アクション作成
tq action create <prompt> --task <task_id> --title "<title>"
```

### 3. 通知の既読マーク

処理済み通知を既読にする:
```bash
gh api -X PATCH /notifications/threads/<thread_id>
```

### 4. 結果サマリ出力

```
GitHub通知処理完了。取得: N件、スキップ: M件、アクション作成: K件。
[各アクションの概要リスト]
```

### 5. 完了報告

`/tq:done` を実行。

## ルール

1. 1通知1アクション。バッチ化しない
2. `gh` CLIのみ使用（GitHub APIトークンは `gh` が管理）
