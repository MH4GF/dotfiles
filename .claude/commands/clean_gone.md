---
description: 全リポジトリの[gone]ブランチとworktreeをクリーンアップ
---

!`ghq list` で得られた各リポジトリに `cd` し、以下を実行:

1. `git fetch --prune`
2. `git branch -v` で `[gone]` ブランチを特定
3. `[gone]` ブランチに紐づくworktreeがあれば `git worktree remove --force` で削除
4. `git branch -D` でブランチ削除

```bash
git branch -v | grep '\[gone\]' | sed 's/^[+* ]//' | awk '{print $1}' | while read branch; do
  worktree=$(git worktree list | grep "\\[$branch\\]" | awk '{print $1}')
  if [ ! -z "$worktree" ] && [ "$worktree" != "$(git rev-parse --show-toplevel)" ]; then
    git worktree remove --force "$worktree"
  fi
  git branch -D "$branch"
done
```

結果をサマリで報告（リポジトリ名と削除ブランチ数）。[gone]ブランチがないリポジトリは省略。
