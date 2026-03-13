---
description: 汎用実装タスク
auto: true
mode: interactive
on_done: classify-next-action
on_cancel: classify-next-action
---
## 事前準備: アクション経緯の把握

作業開始前に、このタスクの全アクション履歴を確認せよ:

```
tq action list --task {{.Task.ID}}
```

- 各アクションの **result** フィールドから、過去の成果・失敗理由・改善提案を把握する
- 同じアプローチの繰り返しを避け、前回の知見を活かして作業を進める

---

{{.Action.Meta.instruction}}

## 手順

1. **プランモードで計画を立てる**
2. **実装する**
3. **E2E動作確認** — テスト実行・ビルド確認等（具体的なコマンドはプロジェクトの CLAUDE.md に従う）
4. **`/simplify` でリファクタリング**
5. **`/parallel-review` でコードレビュー**
6. **コミット** — git のルールはプロジェクトの CLAUDE.md に従う
7. **`/tq:done` で完了報告**

対象: {{.Task.Title}}
{{- if .Task.URL}}
参考: {{.Task.URL}}
{{- end}}
完了したら: /tq:done
