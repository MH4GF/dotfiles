---
description: 通知分類
auto: true
mode: noninteractive
allowed_tools: Bash,Read,WebFetch
timeout: 120
---
以下の通知を分類し、`/tq` スキルに従ってタスクとアクションを作成してください。

## 通知内容
{{index .Action.Meta "notification"}}

## 既存のオープンタスク
{{index .Action.Meta "existing_tasks"}}

## 利用可能なプロンプト
以下のプロンプトから選択すること:

- `implement` — 汎用的な実装タスク
- `self-review` — PR のセルフレビュー
- `respond-review` — レビューコメントへの対応
- `fix-ci` — CI 失敗の修正
- `fix-conflict` — コンフリクト解消
- `merge-pr` — PR マージ

**選択不可**: `classify-gh-notification`, `classify-next-action` はシステム内部用のため選択してはならない。

## プロンプト選択ガイド

通知フィールドに基づき、上から順に最初に該当した条件のプロンプトを選択する:

| 優先 | 条件 | プロンプト |
|---|---|---|
| 1 | `mergeable: "conflicting"` | `fix-conflict` |
| 2 | `ci_failed: true` | `fix-ci` |
| 3 | `review_decision: "changes_requested"` / 未対応レビューコメント | `respond-review` |
| 4 | `review_decision: "approved"` + CI pass + mergeable | `merge-pr` |
| 5 | 自分のPRで未レビュー | `self-review` |
| 6 | その他の実装・修正依頼 | `implement` |

**IMPORTANT: `mergeable` の値を正しく区別すること**
- `"conflicting"` = Gitコンフリクトあり → `fix-conflict`
- `"unstable"` = CIやステータスチェック未通過 → `fix-ci` を検討（コンフリクトではない）
- `"mergeable"` = マージ可能

プロンプト選択前に必ず通知URLにアクセスし、PR/Issueの最新状況を確認すること。通知フィールドだけで判断してはならない。

## 手順

### 0. 関連タスクの調査

通知のURLが既存タスクのURLと一致する場合、そのタスクの過去アクション履歴を確認する:

1. 既存タスク一覧からURLが一致するタスクを探す
2. 一致するタスクがあれば、`/tq` スキルに従いそのタスクのアクション履歴を確認する
3. 必要に応じて通知のURLにアクセスし、PR/Issue の最新状況を確認

この情報を踏まえて、重複アクションの作成を避け、適切な次アクションを判断すること。

### 1. タスクの特定または作成

既存タスクに関連する場合はそのIDを使う。新規タスクの場合:

`/tq` スキルに従い、タスクを作成する（プロジェクト名、タイトル、URLを指定）。

### 2. アクションの作成

`/tq` スキルに従い、アクションを作成する（プロンプト、タスクIDを指定）。

### 3. 対応不要の場合

bot通知、自分のアクション等、対応不要の通知は何も作成せず「対応不要」と出力する。

## ルール
1. 通知が既存タスクに関連する場合は、そのタスクIDを使う
2. 上記プロンプト一覧から適切なアクションを選ぶ
3. 新規タスク作成時、既存プロジェクトに該当しない通知は **works** プロジェクトに分類する
