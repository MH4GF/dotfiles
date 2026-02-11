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

`/collect-permissions` コマンドを実行。
