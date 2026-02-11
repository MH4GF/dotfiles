#!/bin/sh

mkdir -p ~/.config/karabiner/
mkdir -p ~/.config/git/
mkdir -p ~/.config/mise/

ln -sf $(realpath $(dirname ${0}))/.config/karabiner/karabiner.json ~/.config/karabiner/karabiner.json
ln -sf $(realpath $(dirname ${0}))/.config/starship.toml ~/.config/starship.toml
ln -sf $(realpath $(dirname ${0}))/.config/gh/config.yml ~/.config/gh/config.yml
ln -sf $(realpath $(dirname ${0}))/.config/git/ignore ~/.config/git/ignore

mkdir -p ~/.ssh
ln -sf $(realpath $(dirname ${0}))/.ssh/config ~/.ssh/config

ln -sf $(realpath $(dirname ${0}))/.vimrc ~/.vimrc

# Neovim
mkdir -p ~/.config/nvim
ln -sf $(realpath $(dirname ${0}))/.config/nvim/init.lua ~/.config/nvim/init.lua
ln -sf $(realpath $(dirname ${0}))/.zshrc ~/.zshrc
ln -sf $(realpath $(dirname ${0}))/.ideavimrc ~/.ideavimrc
ln -sf $(realpath $(dirname ${0}))/.gitconfig ~/.gitconfig
ln -sf $(realpath $(dirname ${0}))/.tmux.conf ~/.tmux.conf
ln -sf $(realpath $(dirname ${0}))/.config/mise/config.toml ~/.config/mise/config.toml

mkdir -p ~/.config/iterm2/
ln -sf $(realpath $(dirname ${0}))/.config/iterm2/com.googlecode.iterm2.plist ~/.config/iterm2/com.googlecode.iterm2.plist

# Claude settings
mkdir -p ~/.claude
ln -sf $(realpath $(dirname ${0}))/.claude/commands ~/.claude/commands
ln -sf $(realpath $(dirname ${0}))/.claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -sf $(realpath $(dirname ${0}))/.claude/settings.json ~/.claude/settings.json
ln -sf $(realpath $(dirname ${0}))/.claude/hooks ~/.claude/hooks
ln -sfn $(realpath $(dirname ${0}))/.claude/skills ~/.claude/skills

# Claude MCP setup
$(dirname ${0})/setup_claude_mcp.sh
