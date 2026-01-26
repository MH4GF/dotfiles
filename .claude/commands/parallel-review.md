---
description: 複数の観点で並列コードレビューを実行
---

## Task

以下の3つのレビューエージェントを**並列**で実行し、結果を統合して報告する。

### 実行するエージェント

1. **codex-review** - `codex review` CLIによるコードレビュー
2. **code-simplifier:code-simplifier** - コードの簡潔性・保守性の確認
3. **qa:claude-md-checker** - CLAUDE.md準拠チェック

### 実行方法

Task toolで3つのエージェントを**同時に**起動する：

```
subagent_type: "issync:code-reviewer" → コード変更のレビュー
subagent_type: "code-simplifier:code-simplifier" → 簡潔性チェック
subagent_type: "qa:claude-md-checker" → CLAUDE.md準拠チェック
```

加えて、Skillツールで `/codex-review` を実行する。

### 出力形式

各エージェントの結果を以下の形式でまとめる：

```markdown
## レビュー結果サマリー

### Codex Review
[結果]

### Code Simplifier
[結果]

### CLAUDE.md Checker
[結果]

## 対応が必要な項目
[優先度の高い指摘をリストアップ]
```

### ネクストアクション

結果出力後、**AskUserQuestion** ツールでネクストアクションを確認する。
