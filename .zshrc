#!/bin/sh

## 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
## 補完候補を詰めて表示
setopt list_packed
## 補完候補一覧をカラー表示
autoload colors
zstyle ':completion:*' list-colors ''
## コマンドのスペルを訂正
setopt correct

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

  autoload -Uz compinit
  compinit
fi

# ghq list
alias ghql='cd $(ghq root)/$(ghq list | peco)'

# history
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt hist_ignore_all_dups  # 重複するコマンド行は古い方を削除
setopt hist_ignore_dups      # 直前と同じコマンドラインはヒストリに追加しない
setopt hist_reduce_blanks    # 余分な空白は詰めて記録
setopt hist_no_store         # historyコマンドは記録しない

# git
alias gp='git push -u origin head'
alias gpf='git push -u --force-with-lease origin head'

function g () {
    if [[ $# > 0 ]]
    then
            git $@
    else
            git status -s
    fi
}
compdef g=git

# docker
alias dc='docker compose'

# linux
alias ll='ls -laG'

export AWS_SDK_LOAD_CONFIG=1

# wakatime
alias wakatime='docker run --rm -it mh4gf/wakatime-cli'

# oh-my-zsh
plugins=(wakatime)

# textlint
alias textlint='$HOME/.ghq/github.com/MH4GF/my-textlint/node_modules/.bin/textlint -c $HOME/.ghq/github.com/MH4GF/my-textlint/.textlintrc'

# vscode
alias devc='devcontainer open'

# cpp
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:~/cpp/include/

# GPG key
export GPG_TTY=$(tty)

eval "$(direnv hook zsh)"

# Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

zinit load azu/ni.zsh

# asdf
. /opt/homebrew/opt/asdf/libexec/asdf.sh

# starship
eval "$(starship init zsh)"

# zsh-autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# deno
export PATH="/Users/mh4gf/.deno/bin:$PATH"

# go
export PATH="/Users/mh4gf/go/bin:$PATH"

# bun completions
[ -s "/Users/mh4gf/.bun/_bun" ] && source "/Users/mh4gf/.bun/_bun"
export PATH="$HOME/.bun/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

## pnpm
#export PNPM_HOME="/Users/mh4gf/Library/pnpm"
#case ":$PATH:" in
#  *":$PNPM_HOME:"*) ;;
#  *) export PATH="$PNPM_HOME:$PATH" ;;
#esac
## pnpm end

# pnpm
export PNPM_HOME="/Users/mh4gf/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

alias claude="/Users/mh4gf/.claude/local/claude"
