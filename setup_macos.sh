#!/bin/bash
#
# macOS セットアップスクリプト
#
# クリーンインストール前の準備:
#   - AWS設定を1Passwordにバックアップ:
#     cat ~/.aws/credentials | pbcopy → 1Passwordの該当項目を更新
#     cat ~/.aws/config | pbcopy → 1Passwordの該当項目を更新
#
# 使い方（クリーンインストール後）:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/MH4GF/dotfiles/master/setup_macos.sh)"

set -e

echo "🍎 Starting macOS Setup..."

# macOSで実行されているか確認
if [[ "$(uname)" != "Darwin" ]]; then
    echo "This script is only for macOS!"
    exit 1
fi

# Xcode Command Line Toolsのインストール
echo "📦 Installing Xcode Command Line Tools..."
if ! xcode-select -p &> /dev/null; then
    xcode-select --install
    echo "Please complete Xcode Command Line Tools installation and run this script again."
    exit 1
fi

# Homebrewのインストール
echo "🍺 Installing Homebrew..."
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Apple Silicon MacではHomebrewをPATHに追加
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

# Homebrewの更新
echo "🔄 Updating Homebrew..."
brew update
brew upgrade

# リポジトリからBrewfileを取得
echo "📥 Fetching Brewfile..."
curl -fsSL https://raw.githubusercontent.com/MH4GF/dotfiles/master/Brewfile > ~/.Brewfile

# Brewfileからパッケージをインストール
echo "📦 Installing packages from Brewfile..."
brew bundle --global

# 1Password CLIのセットアップ
echo "🔐 Setting up 1Password CLI..."
if command -v op &> /dev/null; then
    echo "Please sign in to 1Password CLI:"
    op signin
fi

# dotfilesのクローンとセットアップ
# 注: SSH鍵は1Passwordで管理。上記でサインイン後、SSH Agentが利用可能
echo "📥 Setting up dotfiles..."
ghq get --update git@github.com:MH4GF/dotfiles.git
(
    cd ~/ghq/github.com/MH4GF/dotfiles && ./setup-nix.sh
)

# mise開発ツールのセットアップ
echo "🛠 Installing development tools with mise..."
if [[ -f ~/.config/mise/config.toml ]]; then
    mise trust ~/.config/mise/config.toml
    mise install
fi

# グローバルnpmパッケージのインストール
echo "📦 Installing global npm packages..."
mise exec -- npm install -g @mh4gf/issync @openai/codex

# macOSシステム環境設定
echo "⚙️  Configuring macOS preferences..."

# 隠しファイルを表示
defaults write com.apple.finder AppleShowAllFiles -bool true

# Finderでパスバーを表示
defaults write com.apple.finder ShowPathbar -bool true

# Finderでステータスバーを表示
defaults write com.apple.finder ShowStatusBar -bool true

# ファイル拡張子を表示
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# 拡張子変更時の警告を無効化
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# キーリピートを有効化
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# キーリピート速度を高速に設定
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# メニューバーにバッテリー残量を表示
defaults write com.apple.menuextra.battery ShowPercent -string "YES"

# Dockに最近使ったアプリを表示しない
defaults write com.apple.dock show-recents -bool false

# ウィンドウをアプリアイコンに最小化
defaults write com.apple.dock minimize-to-application -bool true

# Dockアイテムのスプリングローディングを有効化
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# Dockで起動中アプリにインジケータを表示
defaults write com.apple.dock show-process-indicators -bool true

# Dockからのアプリ起動アニメーションを無効化
defaults write com.apple.dock launchanim -bool false

# Dockを自動的に隠す/表示
defaults write com.apple.dock autohide -bool true

# 非表示アプリのDockアイコンを半透明に
defaults write com.apple.dock showhidden -bool true

# DashboardをSpaceとして表示しない
defaults write com.apple.dock dashboard-in-overlay -bool true

# 電源管理設定
# 電源接続時: スリープしない
sudo pmset -c displaysleep 0
sudo pmset -c sleep 0
# バッテリー時: 15分でスリープ
sudo pmset -b displaysleep 15
sudo pmset -b sleep 15

# 影響を受けるアプリケーションを再起動
echo "🔄 Restarting affected applications..."
killall Finder || true
killall Dock || true
killall SystemUIServer || true

echo "✅ macOS setup complete!"
echo ""
echo "📌 Manual steps required:"
echo "1. Sign in to 1Password and other apps"
echo "2. Configure AWS credentials with: op read \"op://Private/AWS/access_key_id\""
echo "3. Generate GPG key and add to GitHub:"
echo "   gpg --full-generate-key"
echo "   gpg --list-secret-keys --keyid-format=long"
echo "   gpg --armor --export <KEY_ID> | pbcopy"
echo "   # Add to ~/.gitconfig.local: signingkey = <KEY_ID>"
echo "4. Add home directory to Finder sidebar:"
echo "   Finder → Settings (Cmd+,) → Sidebar → Check 'Home'"
echo "5. Configure iTerm2 to load settings from dotfiles:"
echo "   iTerm2 → Preferences (Cmd+,) → General → Preferences"
echo "   - Check 'Load preferences from a custom folder or URL'"
echo "   - Set path to: ~/.config/iterm2"
echo "   - Set 'Save changes' to 'Automatically'"
echo "6. Restart your computer for all changes to take effect"