---
description: 全リポジトリの settings.local.json から許可設定を収集しグローバル設定に統合
allowed-tools: Bash(bash *collect_permissions.sh*), Read(~/.claude/settings.json)
---

スクリプトを実行し、グローバル設定（`~/.claude/settings.json`）に未登録の候補を一覧表示する。

```bash
bash ~/.claude/skills/collect-permissions/scripts/collect_permissions.sh
```

スクリプト出力はフィルタ適用済みの候補リスト。review_guidelines に基づき判断した上で、`~/.claude/settings.json` の `permissions.allow` に直接追加する。

<review_guidelines>
候補表示時に以下を判断し、除外を提案すること:

- `gog`: query系（`gog auth status`等）は許可、操作系（`gog gmail thread modify`等）は除外を提案
- プロジェクト固有の Skill: グローバルに追加すべきか確認
</review_guidelines>
