# レビューコメント対応

レビュワーからのコメントに対応する。フェーズごとにまとめて進め、1件ずつ直列で完了させない。

## Phase 1: 分析（変更なし）

### 1. 未解決コメントの取得

```bash
~/.claude/skills/github-pr/gh-unresolved-threads <URL>
```

### 2. 分類

各コメントを分類:

**対応不要（resolveしない）:**
- コード説明のコメント、FYI的な情報共有、確認済みの指摘
- resolveせずスレッドをそのまま残す。レビュワーの知見や補足情報はスレッド上に残す価値がある

**コード修正不要だがresolveが必要:**
- 別issue/PRで対応する場合 → 対応先issueのURLを貼ってresolve
- nit/optionalに対応しない場合 → 対応しない理由を記載してresolve

**対応が必要:**
- 議論が残っている・回答待ちのスレッド

## Phase 2: 報告・議論

MUST: 分類結果をユーザーに提示し、各コメントの対応方針を議論する。合意なく修正に着手しない。

| # | スレッド | 分類 | 対応案 |
|---|----------|------|--------|
| 1 | 該当箇所の要約 | 対応必要 / 対応不要 | 修正方針 or 不要理由 |
| ... | ... | ... | ... |

判断が必要な項目（値の選定、命名、設計判断など）は、前例調査や根拠を添える。

未解決コメントが0件の場合 → その旨を報告して完了。

## Phase 3: 実行

合意した方針に従い、バッチで対応する。

### ステップ1: 対応宣言

全件に「対応します」とコメント（作業前に対応意思を先んじて伝える）。

### ステップ2: 実装

全件の修正をまとめて実施・コミット。

### ステップ3: push

コミットをリモートにpushする。GitHub上でコミットハッシュをリンク化するために必要。

### ステップ4: 完了報告

全件に完了コメント+resolveをまとめて実行。

完了コメントには対応理由を添える。自明な場合は簡潔でよい。

<example>
# Good: 理由あり
対応しました。nilチェックが漏れておりpanicの可能性がありました。

# Good: 自明な場合
対応しました。typo修正です。

# Bad: 理由なし
対応しました。
</example>

## GraphQL操作リファレンス

### スレッドへの返信

`gh-unresolved-threads`の出力に含まれる`id`（THREAD_ID）を使って返信する:

```bash
gh api graphql -f query='
  mutation {
    addPullRequestReviewThreadReply(input: {
      pullRequestReviewThreadId: "<THREAD_ID>"
      body: "返信内容"
    }) { comment { id } }
  }'
```

### スレッドのresolve

```bash
gh api graphql -f query='
  mutation {
    resolveReviewThread(input: {threadId: "<THREAD_ID>"}) {
      thread { isResolved }
    }
  }'
```

返信とresolveを両方行う場合は、返信→resolveの順で実行する。
