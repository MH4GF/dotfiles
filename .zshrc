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
alias gp='git push -u origin $(git branch --show-current)'
alias gpf='git push -u --force-with-lease origin $(git branch --show-current)'

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

# neovim + telescope
alias nf="nvim +\"lua vim.defer_fn(function() require('telescope.builtin').find_files() end, 100)\""
alias ng="nvim +\"lua vim.defer_fn(function() require('telescope.builtin').live_grep() end, 100)\""

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

# # pnpm
# export PNPM_HOME="/Users/mh4gf/Library/pnpm"
# case ":$PATH:" in
#   *":$PNPM_HOME:"*) ;;
#   *) export PATH="$PNPM_HOME:$PATH" ;;
# esac
# # pnpm end

alias claude="/Users/mh4gf/.claude/local/claude"

# # pnpm
# export PNPM_HOME="/Users/mh4gf/Library/pnpm"
# case ":$PATH:" in
#   *":$PNPM_HOME:"*) ;;
#   *) export PATH="$PNPM_HOME:$PATH" ;;
# esac
# # pnpm end

# Draft PRを作成してCIが通ったら自動でreadyにする
pr_auto_ready() {
  local checks_status
  local timeout=${1:-600}  # デフォルト10分
  local check_interval=10
  local elapsed=0
  
  # PRがdraftかチェック
  local is_draft=$(gh pr view --json isDraft --jq '.isDraft' 2>/dev/null)
  if [ "$is_draft" != "true" ]; then
    echo "Current PR is not a draft"
    return 0
  fi
  
  local pr_number=$(gh pr view --json number --jq '.number' 2>/dev/null)
  echo "Monitoring PR #$pr_number for check completion..."
  
  while [ $elapsed -lt $timeout ]; do
    # チェック状況を取得（WIPを除外してカウント）
    total_checks=$(gh pr checks 2>/dev/null | grep -v "^$" | grep -v "^WIP" | wc -l | tr -d ' ')
    passed_checks=$(gh pr checks 2>/dev/null | grep -v "^WIP" | grep "pass" | wc -l | tr -d ' ')
    
    if [ "$total_checks" -gt 0 ] && [ "$total_checks" -eq "$passed_checks" ]; then
      echo "All checks passed! Would convert PR to ready (dry-run mode)"
      echo "Command would run: gh pr ready"
      echo "PR #$pr_number would be ready for review"
      return 0
    fi
    
    echo "Waiting for checks to complete... (${elapsed}s/${timeout}s)"
    echo "Status: $passed_checks/$total_checks checks passed"
    
    # 失敗・待機中のチェックを表示（WIPを除外）
    gh pr checks 2>/dev/null | grep -v "pass" | grep -v "^WIP" | while read -r line; do
      if [ -n "$line" ]; then
        echo "  Waiting: $line"
      fi
    done
    sleep $check_interval
    elapsed=$((elapsed + check_interval))
  done
  
  echo "Timeout reached. Some checks may still be running."
  return 1
}

# Load secrets if exists
[ -f ~/.zsh_secrets ] && source ~/.zsh_secrets
