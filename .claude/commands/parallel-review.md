---
description: 複数の観点で並列コードレビューを実行
---

## Task

以下の3つのレビューを**並列**で実行し、結果を統合して報告する。

### 実行するレビュー

1. **codex-review** - `codex review` CLIによるコードレビュー
2. **qa:claude-md-checker** - CLAUDE.md準拠チェック
3. **simplify** - コードの簡潔性・保守性・再利用性・品質・効率性チェックと修正

### 実行方法

以下を**同時に**起動する：

```
Agent tool: subagent_type: "qa:claude-md-checker" → CLAUDE.md準拠チェック
Skill tool: `/codex-review` → コードレビュー
Skill tool: `/simplify` → 簡潔性・品質チェック
```

### 出力形式

各レビューの結果を以下の形式でまとめる：

```markdown
## レビュー結果サマリー

### Codex Review
[結果]

### CLAUDE.md Checker
[結果]

### Simplify
[結果]

## 対応が必要な項目
[優先度の高い指摘をリストアップ]
```

### ネクストアクション

結果出力後、**AskUserQuestion** ツールでネクストアクションを確認する。
