# Neovim 設定ガイド

このドキュメントは `.config/nvim/init.lua` で設定されているプラグインとキーマッピングの使い方をまとめたものです。

## 基本設定

- **リーダーキー**: スペース
- **ローカルリーダー**: `\`
- タブ幅: 2スペース
- システムクリップボード連携: 有効

## 基本キーマッピング

| キー | モード | 動作 |
|------|--------|------|
| `jj` | Insert | ESCでノーマルモードへ |
| `<leader>r` | Normal | 設定を再読み込み |

## ファイル操作

### ファイルパスのコピー

| キー | モード | 動作 |
|------|--------|------|
| `<leader>cp` | Normal | 相対ファイルパスをコピー |
| `<leader>cc` | Visual | ファイルパスと選択コードをフォーマット付きでコピー |

コピー形式: `@path/to/file.txt` + コードブロック

### GitHub 連携

| キー | モード | 動作 |
|------|--------|------|
| `<leader>gh` | Normal | 現在のファイルをGitHubで開く（現在のコミット） |
| `<leader>gh` | Visual | 選択行をGitHubで開く（現在のコミット） |

## プラグイン

### Telescope（ファジーファインダー）

**キーマッピング:**

| キー | 動作 |
|------|------|
| `<leader>ff` | ファイル検索（隠しファイル含む、gitignoreも検索対象） |
| `<leader>fg` | テキスト検索（live grep） |
| `<leader>fb` | バッファ一覧 |

**Telescope内の操作:**

- `Ctrl+j/k` または `↓/↑`: 候補移動
- `Enter`: 選択
- `Ctrl+c` または `Esc`: キャンセル
- `Ctrl+u/d`: プレビューのスクロール

### vim-fugitive（Git統合）

**キーマッピング:**

| キー | 動作 |
|------|------|
| `<leader>gs` | Git status（インタラクティブ） |
| `<leader>gd` | ステージ済み差分を表示 |

**Git statusバッファ内の操作:**

| キー | 動作 |
|------|------|
| `-` | ファイルをステージング/アンステージング |
| `X` | ファイルの変更を破棄（git restore） |
| `=` | インライン差分表示 |
| `dd` | diff splitで差分表示 |
| `dv` | vertical diff splitで差分表示 |
| `cc` | コミットメッセージ入力 |
| `ca` | コミットを修正（amend） |

**その他の便利なコマンド:**

```vim
:Git blame          " 現在行のコミット履歴
:Git log            " コミットログ
:Gdiffsplit         " 差分を横分割で表示
:Git commit         " コミット
:Git push           " プッシュ
```

### LSP（Language Server Protocol）

**自動インストールされる言語サーバー:**
- TypeScript/JavaScript: ts_ls

**キーマッピング（LSP有効時のみ）:**

| キー | 動作 |
|------|------|
| `F12` | 定義へジャンプ |
| `Shift+F12` (`F24`) | 参照一覧を表示 |
| `K` | ホバー情報表示（型、ドキュメント） |
| `gi` | 実装へジャンプ |
| `Ctrl+k` | シグネチャヘルプ |
| `Ctrl+x Ctrl+o` | Insert modeで補完 |

## Tips

### よく使うワークフロー

**ファイル検索からジャンプ:**
```
<leader>ff → ファイル名入力 → Enter
```

**コードの一部を共有:**
```
Visual modeで選択 → <leader>cc → Claude Codeにペースト
```

**変更を確認してコミット:**
```
<leader>gs → 変更確認 → - でステージング → cc でコミット
```

**GitHubで特定行を共有:**
```
Visual modeで行選択 → <leader>gh → ブラウザが開く
```

### Mason でLSPサーバーを管理

```vim
:Mason              " Masonを開く（LSPサーバーのインストール管理）
:LspInfo            " 現在のバッファで有効なLSP情報
```

## トラブルシューティング

### LSPが動かない場合

```vim
:LspInfo            " LSPの状態確認
:Mason              " 必要なサーバーがインストールされているか確認
```

### 設定が反映されない場合

```
<leader>r           " 設定を再読み込み
```

または Neovim を再起動
