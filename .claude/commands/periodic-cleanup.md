---
description: 全リポジトリのgone branchクリーンアップとsettings.local.json の設定収集
---

## Task

### 1. gone branchクリーンアップ

```bash
ghq list | grep -v worktrees
```

上記で得られた各リポジトリに `cd` し、`/clean_gone` コマンドと同等の処理を実行。

結果をサマリで報告（リポジトリ名と削除ブランチ数）。

### 2. settings.local.json 統合

同じリポジトリ一覧から `.claude/settings.local.json` を探し、グローバル設定 `/Users/mh4gf/ghq/github.com/MH4GF/dotfiles/.claude/settings.json` に未登録の許可設定を追加。
