---
description: Watch GitHub notifications
mode: interactive
---
GitHub通知を取得・分類し、必要なタスク/アクションを作成する。

## 手順

### 1. 通知取得

```bash
gh api /notifications --paginate --jq '.[] | {id: .id, reason: .reason, subject_type: .subject.type, title: .subject.title, repo: .repository.full_name, subject_url: .subject.url, url: .subject.url}' 2>/dev/null
```

通知が0件なら「通知なし」と出力して終了。

### 2. 各通知の詳細取得と分類

各通知について:

#### 2a. PR/Issueの詳細取得

subject_typeに応じて詳細を取得:

- **PullRequest**: `gh pr view <url> --json url,state,author,headRefName,reviewDecision,mergeStateStatus,statusCheckRollup,isDraft`
- **Issue**: `gh issue view <url> --json url,state,author`
- **Discussion/Release**: `gh api` で情報取得

subject_urlからPR/Issue番号を抽出するには:
```bash
# subject_url例: https://api.github.com/repos/owner/repo/pulls/123
# repo名と番号で gh pr view
gh pr view 123 --repo owner/repo --json url,state,author,headRefName,reviewDecision,mergeStateStatus,statusCheckRollup,isDraft
```

#### 2b. スキップ判定

以下は通知を既読にしてスキップ:
- merged/closed の PR/Issue
- bot（dependabot, renovate, github-actions等）からの通知で対応不要なもの
- Discussion/Release の通知

#### 2c. リモートアクションPR検出

PRのheadRefNameが `tq-<数字>-` パターンにマッチする場合:
```bash
# アクションIDを抽出（例: tq-42-fix-bug → 42）
tq action done <action_id> --result "remote:pr=<pr_url>"
```
既読にしてスキップ。

#### 2d. 分類とアクション作成

要対応の通知について、以下の優先順で該当するプロンプトを選択:

| 優先 | 条件 | プロンプト |
|---|---|---|
| 1 | `mergeStateStatus: "BEHIND"` or conflicting | `fix-conflict` |
| 2 | statusCheckRollup に failure あり | `fix-ci` |
| 3 | `reviewDecision: "CHANGES_REQUESTED"` / 未対応レビューコメント | `respond-review` |
| 4 | `reviewDecision: "APPROVED"` + CI pass + mergeable | `merge-pr` |
| 5 | 自分のPRで未レビュー | `self-review` |
| 6 | その他の実装・修正依頼 | `implement` |

**選択不可**: `classify-gh-notification`, `classify-next-action`, `watch-gh-notifications` はシステム内部用。

通知のURLが既存タスクのURLと一致する場合はそのタスクIDを使う。一致しない場合は新規タスク作成。

```bash
# 既存タスク確認
tq task list --status open

# 新規タスク作成（既存プロジェクトに該当しない場合は works プロジェクトに分類）
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

以下を出力（action.resultに保存される）:
```
GitHub通知処理完了。取得: N件、スキップ: M件、アクション作成: K件。
[各アクションの概要リスト]
```

## ルール

1. 通知が既存タスクに関連する場合は、そのタスクIDを使う
2. 新規タスク作成時、既存プロジェクトに該当しない通知は **works** プロジェクトに分類する
3. 1通知1アクション。バッチ化しない
4. `gh` CLIのみ使用。GitHub APIトークンは `gh` が管理
