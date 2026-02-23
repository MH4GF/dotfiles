# マージ判断

判断レベル: **L1（報告+提案）** — 初期値。AIが全基準の判断根拠を提示し、ユーザーの確認を待つ。

## 手順

### 1. セルフレビュー

[self-review.md](self-review.md)を実行し、未解決の指摘がないことを確認。指摘が残っている場合はマージに進まない。

### 2. マージゲート

approvedは必要条件であり十分条件ではない。以下の全てを確認する。

```bash
gh pr view <URL> --json state,title,mergeable,reviewDecision,reviews,mergeStateStatus,updatedAt
```

#### 承認ステータス（必要条件）

必要なApprove数はプロジェクトのCLAUDE.mdを参照。Approve不足 → マージ不可。

#### mainとの乖離

取得済みの `mergeable`, `mergeStateStatus`, `updatedAt` を使用:
- mergeableがMERGEABLEでない → コンフリクト解消が必要
- 最終更新から3日以上経過 → mainの変更がセマンティックコンフリクトを起こしていないか確認
- mergeStateStatusがBLOCKED → CI失敗やブランチ保護ルール違反

#### CI / 依存関係

- CIが全てグリーンか（CI実行中 → 他の基準を先に評価、CI完了後に最終判断）
- 依存PRがないか（マージ順序の制約）

### 3. マージ実行

1. レビュワーに感謝のコメントを投稿（レビュー内容を踏まえた短い感謝。定型文NG）
2. マージ実行

```bash
gh pr comment <URL> --body "<レビュー内容に応じた感謝コメント>"
gh pr merge <URL> --merge
```

実行後、後続PRがあれば報告する。

## 判断ログ

誤判断があった場合、ここに記録し基準を更新する。

<!-- 例:
- YYYY-MM-DD: PR #NNN をマージ提案したが、XXXの考慮が不足していた → 基準Nに「XXX」を追加
-->
