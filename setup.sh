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
ln -sf $(realpath $(dirname ${0}))/.config/mise/config.toml ~/.config/mise/config.toml

# Claude settings
mkdir -p ~/.claude
ln -sf $(realpath $(dirname ${0}))/.claude/commands ~/.claude/commands
ln -sf $(realpath $(dirname ${0}))/.claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -sf $(realpath $(dirname ${0}))/.claude/settings.json ~/.claude/settings.json

# Serena config
mkdir -p ~/.serena
ln -sf $(realpath $(dirname ${0}))/.serena/serena_config.yml ~/.serena/serena_config.yml

# Claude MCP setup
$(dirname ${0})/setup_claude_mcp.sh
