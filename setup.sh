#!/bin/sh

mkdir -p ~/.config/fish
ln -sf $(pwd)/.config/fish/config.fish ~/.config/fish/config.fish

mkdir -p ~/.config/karabiner/
ln -sf $(pwd)/.config/karabiner/karabiner.json ~/.config/karabiner/karabiner.json

ln -sf $(pwd)/.vimrc ~/.vimrc
ln -sf $(pwd)/.ideavimrc ~/.ideavimrc
ln -sf $(pwd)/.gitignore_global ~/.gitignore_global
