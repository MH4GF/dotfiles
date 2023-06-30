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

# code-server
fetch_instance_id () {
    aws --profile ort ec2 describe-instances \
        --filter "Name=tag-key,Values=Name" "Name=tag-value,Values=$1" \
        --query "Reservations[0].Instances[0].InstanceId" \
        --output text
}

function start_ide () {
    local instance_name=mh4gf-code-server
    local instance_id=$(echo $(fetch_instance_id mh4gf-code-server))

    if [ -n "$instance_id" ]; then
        aws --profile ort ec2 start-instances --instance-ids ${instance_id}
    else
        echo "could not found instance with ${instance_name}"
    fi
}

stop_ide () {
    local instance_name=mh4gf-code-server
    local instance_id=$(echo $(fetch_instance_id mh4gf-code-server))

    if [ -n "$instance_id" ]; then
        aws --profile ort ec2 stop-instances --instance-ids ${instance_id}
    else
        echo "could not found instance with ${instance_name}"
    fi
}

# vscode
alias devc='devcontainer open'

# cpp
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:~/cpp/include/

# GPG key
export GPG_TTY=$(tty)

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

# asdf
. /opt/homebrew/opt/asdf/libexec/asdf.sh
