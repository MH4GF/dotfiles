#!/bin/sh

mkdir -p ~/.config/mise/
ln -sf $(realpath $(dirname ${0}))/.config/mise/config.toml ~/.config/mise/config.toml

# tq prompts
mkdir -p ~/.config/tq
ln -sfn $(realpath $(dirname ${0}))/.config/tq/prompts ~/.config/tq/prompts

# bin scripts
mkdir -p ~/.local/bin
ln -sf $(realpath $(dirname ${0}))/bin/cc-human-review ~/.local/bin/cc-human-review
