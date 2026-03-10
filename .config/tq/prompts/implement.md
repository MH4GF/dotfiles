---
description: 汎用実装タスク
auto: true
mode: interactive
on_done: classify-next-action
---
{{.Action.Meta.instruction}}

## 手順

1. **プランモードで計画を立てる**
2. **実装する**
3. **動作確認** — テスト実行・ビルド確認等（具体的なコマンドはプロジェクトの CLAUDE.md に従う）
4. **コミット** — git のルールはプロジェクトの CLAUDE.md に従う
5. **`/tq:done` で完了報告**

対象: {{.Task.Title}}
{{- if .Task.URL}}
参考: {{.Task.URL}}
{{- end}}
完了したら: /tq:done
