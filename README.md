# dotfiles

My personal dotfiles and macOS setup scripts.

## 🚀 Quick Start

### Full macOS Setup (New Machine)

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/MH4GF/dotfiles/master/setup_macos.sh)"
```

This will:
- Install Xcode Command Line Tools
- Install Homebrew
- Install all packages from Brewfile
- Setup dotfiles symlinks
- Configure macOS system preferences
- Install development tools via mise

### Dotfiles Only Setup

If you just want to setup the dotfiles without installing packages:

```bash
./setup.sh
```

## 📁 Structure

- `Brewfile` - Homebrew packages and applications
- `setup_macos.sh` - Complete macOS setup script
- `setup.sh` - Dotfiles symlink setup only
- `.config/` - Application configurations
- `.zshrc` - Zsh configuration
- `.gitconfig` - Git configuration
- `mise.toml` - mise tool management

## 🔧 Manual Setup

After running the setup scripts, you'll need to:

1. Sign in to 1Password
2. Configure AWS credentials (if needed)
3. Restart your computer for all macOS preferences to take effect

## 📝 Customization

- Copy `.gitconfig.local.sample` to `.gitconfig.local` for personal git settings
- Copy `.zsh_secrets.example` to `.zsh_secrets` for private environment variables