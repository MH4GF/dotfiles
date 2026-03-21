---
description: 他者PRレビュー
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

PR {{ index .Task.Meta "url" }} をレビューせよ。

/github-pr スキルのレビューフローに従うこと。
コードを読み、問題点や改善提案があればレビューコメントを残し、approve/request changesを判断する。

完了したら: /tq:done
