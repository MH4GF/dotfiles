#!/bin/sh

mkdir -p ~/.config/karabiner/
mkdir -p ~/.config/git/

ln -sf $(dirname ${0})/.config/karabiner/karabiner.json ~/.config/karabiner/karabiner.json
ln -sf $(dirname ${0})/.config/starship.toml ~/.config/starship.toml
ln -sf $(dirname ${0})/.config/gh/config.yml ~/.config/gh/config.yml
ln -sf $(dirname ${0})/.config/git/ignore ~/.config/git/ignore

mkdir -p ~/.ssh
ln -sf $(dirname ${0})/.ssh/config ~/.ssh/config

ln -sf $(dirname ${0})/.vimrc ~/.vimrc

# Neovim
mkdir -p ~/.config/nvim
ln -sf $(dirname ${0})/.config/nvim/init.lua ~/.config/nvim/init.lua
ln -sf $(dirname ${0})/.zshrc ~/.zshrc
ln -sf $(dirname ${0})/.ideavimrc ~/.ideavimrc
ln -sf $(dirname ${0})/.gitconfig ~/.gitconfig
ln -sf $(dirname ${0})/.tool-versions ~/.tool-versions
ln -sf $(dirname ${0})/.asdfrc ~/.asdfrc

# Claude settings
mkdir -p ~/.claude
ln -sf $(dirname ${0})/.claude/commands ~/.claude/commands
ln -sf $(dirname ${0})/.claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -sf $(dirname ${0})/.claude/settings.json ~/.claude/settings.json

# Claude MCP setup
$(dirname ${0})/setup_claude_mcp.sh
