---
description: 汎用実装タスク
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

1. **ブランチを作成** — `tq-{{.Action.ID}}-<slug>` 形式（例: `tq-{{.Action.ID}}-add-feature`）
2. **プランモードで計画を立てる**
3. **実装する**
4. **動作確認** — テスト実行・ビルド確認等（具体的なコマンドはプロジェクトの CLAUDE.md に従う）
5. **コミット & プッシュ** — git のルールはプロジェクトの CLAUDE.md に従う
6. **Pull Request を作成** — これが完了シグナルになる

対象: {{.Task.Title}}
{{- if get .Task.Meta "url"}}
参考: {{ get .Task.Meta "url" }}
{{- end}}
