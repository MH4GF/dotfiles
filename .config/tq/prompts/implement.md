---
description: 汎用実装タスク
auto: true
mode: interactive
on_done: classify-next-action
on_cancel: classify-next-action
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
