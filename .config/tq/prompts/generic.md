---
description: 汎用対話タスク
auto: true
mode: interactive
on_done: classify-next-action
on_cancel: classify-next-action
---
{{.Action.Meta.instruction}}

対象: {{.Task.Title}}
{{- if .Task.URL}}
参考: {{.Task.URL}}
{{- end}}
完了したら: /tq:done
