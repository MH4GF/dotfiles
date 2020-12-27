#!/bin/sh

mkdir -p ~/.config/fish
ln -sf $(dirname ${0})/.config/fish/config.fish ~/.config/fish/config.fish

mkdir -p ~/.config/karabiner/
ln -sf $(dirname ${0})/.config/karabiner/karabiner.json ~/.config/karabiner/karabiner.json

ln -sf $(dirname ${0})/.vimrc ~/.vimrc
ln -sf $(dirname ${0})/.zshrc ~/.zshrc
ln -sf $(dirname ${0})/.zsh_profile ~/.zsh_profile
ln -sf $(dirname ${0})/.ideavimrc ~/.ideavimrc
ln -sf $(dirname ${0})/.gitignore_global ~/.gitignore_global
