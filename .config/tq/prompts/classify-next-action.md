---
description: 完了アクションの結果から次アクションを判断
mode: noninteractive
---
タスク「{{.Task.Title}}」({{ get .Task.Meta "url" }}) の前アクションが完了した。
結果を分析し、Phase A → B → C を順に実行せよ。

## 事前準備

このタスクの全アクション履歴を確認:

```
tq action list --task {{.Task.ID}}
```

各アクションの **result** からこれまでの経緯・成果・失敗理由を把握する。

タスクに関連するPR URLがあれば `tq task list` で同じPRを扱う別タスクを検索する。別タスクが存在し、そちらにrunning中のアクションがあれば**重複タスク**と判断→`/tq` スキルに従いタスク {{.Task.ID}} を archived に更新し、Phase C（result に重複先タスクIDを記録）へ進む。

<predecessor_result>
{{index .Action.Meta "predecessor_result"}}
</predecessor_result>

<constraints>
- **predecessor_resultの批判的評価**: result内に未完了シグナル（未検証、試行錯誤中、次ステップあり、Test plan未チェック項目等）がある場合、それを無視して完了判定してはならない
- **重複チェック**: 同じテンプレートのアクティブなアクション（pending / running / waiting_human）がある場合は作成しない
- **重複エラー**（"blocked: active action already exists"）: 前アクションから状況が変わっており再実行が妥当なら強制再作成、そうでなければスキップ
- **外部ブロッカー**: 前アクションが外部要因（レビュー待ち・Approve不足・外部チーム待ち・顧客確認待ち等）で目的未達の場合、同じテンプレートのアクションを再作成してはならない。自動化では状況を変えられないため、アクション未作成のまま Phase C へ進む
- **選択不可**: `classify-gh-notification`, `classify-next-action` はシステム内部用のため選択禁止
</constraints>

---

## Phase A: 改善提案の抽出

前アクションの結果に「改善提案」「TODO」「別タスクで実施」「今後の課題」等があれば、以下をすべて満たすもののみタスク化する:

- タスク管理オーバーヘッドに見合う作業量がある
- 具体的で独立したアクションにつながる（1行の軽微な修正や曖昧な提案は不可）
- YAGNI に該当しない

`/tq` スキルに従い、プロジェクト {{.Project.Name}} にタスクを作成する。該当なしなら Phase B へ。

---

## Phase B: 次アクション判断

### テンプレート
- `implement` — 汎用実装（meta の instruction に具体的な指示を含めること）
- `self-review` — PR セルフレビュー
- `respond-review` — レビューコメント対応
- `fix-ci` — CI 失敗修正
- `fix-conflict` — コンフリクト解消
- `merge-pr` — PR マージ

### 判断手順
1. 前アクションの結果とアクション履歴から、次に必要なアクションを判断する
2. constraints の重複チェック・外部ブロッカーチェックを行う
3. 問題なければ `/tq` スキルに従いタスク {{.Task.ID}} にアクションを作成する
4. アクションを作成した場合は Phase C をスキップし完了へ進む

---

## Phase C: タスク完了判定（Phase B でアクション未作成時のみ）

全アクション履歴を踏まえ、タスク「{{.Task.Title}}」({{ get .Task.Meta "url" }}) の目的が達成済みか判定する。

- 以下をすべて確認した上で完了と判定する:
  - PRマージ済みだけでは完了の十分条件にならない
  - アクション result 内の Test plan に未チェック項目がないこと
  - アクション result 内に継続意図（試行錯誤中、次ステップあり等）がないこと
- 完了していれば `/tq` スキルに従いタスク {{.Task.ID}} を done に更新
- 判断できない場合は何もしない

---

完了したら `/tq:done` を実行する。result に判断過程を簡潔に記録（3-5行）:

- **Phase A**: 改善提案の有無。抽出時はタスクID、スキップ時は理由を記載
- **Phase B**: アクション作成の有無。作成時はテンプレート名と理由、未作成時は理由を記載
- **Phase C**: 実行時のみ、完了判定結果と理由を記載
