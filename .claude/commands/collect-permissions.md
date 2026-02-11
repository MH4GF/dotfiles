---
description: 全リポジトリの settings.local.json から許可設定を収集しグローバル設定に統合
---

全リポジトリの `.claude/settings.local.json` から `permissions.allow` を収集し、グローバル設定に未登録のエントリを追加する。

<target>
グローバル設定: `~/.claude/settings.json`
</target>

手順:
1. !`ghq list` で全リポジトリ取得
2. 各リポジトリの `.claude/settings.local.json` から `permissions.allow` を収集（node_modules除外）
3. グローバル設定と差分を取り、未登録エントリを一覧表示
4. ユーザー確認後にグローバル設定へ追加
5. サマリ報告（収集元リポジトリ数・追加エントリ数）

<constraints>
- `permissions.deny` または `permissions.ask` に含まれるエントリは追加しない
- 追加前に必ずユーザー確認を取る
</constraints>
