---
description: 全リポジトリの settings.local.json から許可設定を収集しグローバル設定に統合
allowed-tools: Bash(bash *collect_permissions.sh*)
---

スクリプトを実行し、グローバル設定（`~/.claude/settings.json`）に未登録の候補を一覧表示する。

```bash
bash ~/.claude/skills/collect-permissions/scripts/collect_permissions.sh
```

スクリプト出力はフィルタ適用済みの候補リスト。以下の手順で処理:

1. 候補をカテゴリ別に整理して表示
2. ユーザー確認後、承認されたエントリを `~/.claude/settings.json` の `permissions.allow` に追加
3. サマリ報告

<review_guidelines>
候補表示時に以下を判断し、除外を提案すること:

- `gog`: query系（`gog auth status`等）は許可、操作系（`gog gmail thread modify`等）は除外を提案
- プロジェクト固有の Skill: グローバルに追加すべきか確認
</review_guidelines>
