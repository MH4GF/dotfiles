---
description: リモート実装タスク
mode: remote
on_done: classify-next-action
on_cancel: classify-next-action
---
{{.Action.Meta.instruction}}

## 手順

1. **ブランチを作成** — `tq-{{.Action.ID}}-<slug>` 形式（例: `tq-{{.Action.ID}}-add-feature`）
2. **プランモードで計画を立てる**
3. **実装する**
4. **動作確認** — テスト実行・ビルド確認等（具体的なコマンドはプロジェクトの CLAUDE.md に従う）
5. **コミット & プッシュ** — git のルールはプロジェクトの CLAUDE.md に従う
6. **Pull Request を作成** — これが完了シグナルになる

対象: {{.Task.Title}}
{{- if .Task.URL}}
参考: {{.Task.URL}}
{{- end}}
