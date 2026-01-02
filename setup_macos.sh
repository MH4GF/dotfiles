#!/bin/bash
#
# macOS セットアップスクリプト
#
# 使い方（クリーンインストール後）:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/MH4GF/dotfiles/master/setup_macos.sh)"

set -e

echo "🍎 Starting macOS Setup..."

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "This script is only for macOS!"
    exit 1
fi

# Install Xcode Command Line Tools
echo "📦 Installing Xcode Command Line Tools..."
if ! xcode-select -p &> /dev/null; then
    xcode-select --install
    echo "Please complete Xcode Command Line Tools installation and run this script again."
    exit 1
fi

# Install Homebrew
echo "🍺 Installing Homebrew..."
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

# Update Homebrew
echo "🔄 Updating Homebrew..."
brew update
brew upgrade

# Get Brewfile from repository
echo "📥 Fetching Brewfile..."
curl -fsSL https://raw.githubusercontent.com/MH4GF/dotfiles/master/Brewfile > ~/.Brewfile

# Install packages from Brewfile
echo "📦 Installing packages from Brewfile..."
brew bundle --global

# Setup 1Password CLI
echo "🔐 Setting up 1Password CLI..."
if command -v op &> /dev/null; then
    echo "Please sign in to 1Password CLI:"
    op signin
fi

# Clone and setup dotfiles
# Note: SSH keys are managed by 1Password. After signing in above, SSH Agent is available.
echo "📥 Setting up dotfiles..."
ghq get --update git@github.com:MH4GF/dotfiles.git
~/ghq/github.com/MH4GF/dotfiles/setup.sh

# Setup mise tools
echo "🛠 Installing development tools with mise..."
if [[ -f ~/.config/mise/config.toml ]]; then
    mise install
fi

# Install global npm packages
echo "📦 Installing global npm packages..."
mise exec -- npm install -g @mh4gf/issync @openai/codex

# macOS System Preferences
echo "⚙️  Configuring macOS preferences..."

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show path bar in Finder
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar in Finder
defaults write com.apple.finder ShowStatusBar -bool true

# Show file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Disable warning when changing file extensions
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Enable key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Set fast key repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Show battery percentage in menu bar
defaults write com.apple.menuextra.battery ShowPercent -string "YES"

# Don't show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

# Minimize windows into their application's icon
defaults write com.apple.dock minimize-to-application -bool true

# Enable spring loading for all Dock items
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true

# Don't animate opening applications from the Dock
defaults write com.apple.dock launchanim -bool false

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Make Dock icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true

# Don't show Dashboard as a Space
defaults write com.apple.dock dashboard-in-overlay -bool true

# Restart affected applications
echo "🔄 Restarting affected applications..."
killall Finder || true
killall Dock || true
killall SystemUIServer || true

echo "✅ macOS setup complete!"
echo ""
echo "📌 Manual steps required:"
echo "1. Sign in to 1Password and other apps"
echo "2. Configure AWS credentials with: op read \"op://Private/AWS/access_key_id\""
echo "3. Restart your computer for all changes to take effect"