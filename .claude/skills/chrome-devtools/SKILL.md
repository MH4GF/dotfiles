---
name: chrome-devtools
description: |
  Chrome DevTools MCPを使用したブラウザ操作・検査スキル。ページの視覚的検査、DOM構造確認、スクリーンショット取得に使用。

  **トリガー:** "DevTools"、"chrome-devtools"、"開発者ツール"の言及、またはブラウザでのページ検査要求。

  **重要:** トークン量削減のため、必ずTask toolでサブエージェントとして実行すること。
---

# Chrome DevTools

## 実行ルール（必須）

**すべての操作はTask toolでサブエージェントとして実行する。**

```
Task tool:
  subagent_type: "general-purpose"
  prompt: |
    chrome-devtools MCPで[タスク]を実行。

    手順:
    1. mcp__chrome-devtools__navigate_page で URL遷移
    2. mcp__chrome-devtools__take_snapshot で DOM構造取得
    3. mcp__chrome-devtools__take_screenshot で視覚確認

    結果を報告してください。
```

## ページ検査フロー

1. `navigate_page` → URL遷移
2. `take_snapshot` → 要素UID取得（操作前に必須）
3. `take_screenshot` → 視覚的確認

## 主要ツール

| ツール | 用途 |
|--------|------|
| `navigate_page` | URL遷移、リロード |
| `take_snapshot` | DOM構造・要素UID取得 |
| `take_screenshot` | スクリーンショット |
| `click` | 要素クリック（uid必要） |
| `fill` | テキスト入力（uid必要） |
| `list_console_messages` | コンソール確認 |
| `list_network_requests` | ネットワーク確認 |
