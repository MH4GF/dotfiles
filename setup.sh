#!/bin/sh

mkdir -p ~/.config/fish
ln -sf $(pwd)/.config/fish/config.fish ~/.config/fish/config.fish
ln -sf $(pwd)/.vimrc ~/.vimrc
ln -sf $(pwd)/.ideavimrc ~/.ideavimrc
ln -sf $(pwd)/.gitignore_global ~/.gitignore_global
