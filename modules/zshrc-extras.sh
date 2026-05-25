# Inlined into programs.zsh.initContent via builtins.readFile.
# Kept as a separate .sh file so the shell snippets get syntax highlighting
# and avoid Nix indented-string escape headaches.

# Extra history options not covered by programs.zsh.history
setopt hist_reduce_blanks
setopt hist_no_store

# Git commit lock wrapper (for multi-session safety)
git() {
    local GITDIR=$(command git rev-parse --show-toplevel 2>/dev/null)/.git
    if [[ -d "$GITDIR" ]]; then
        flock "$GITDIR" command git "$@"
    else
        command git "$@"
    fi
}

function g () {
    if [[ $# > 0 ]]
    then
            git $@
    else
            git status -s
    fi
}
compdef g=git

# claude code - reset bracketed paste mode on exit
# https://github.com/anthropics/claude-code/issues/3134
claude() {
    command claude "$@"
    printf '\e[?2004l'
}

# Runtime env vars (depend on shell-time commands)
export GITHUB_TOKEN=$(gh auth token)
export GPG_TTY=$(tty)

# oh-my-zsh plugin list (vestigial: no framework loaded; preserved as-is)
plugins=(wakatime)

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

# mise (replaced by programs.mise in Phase 8)
eval "$(mise activate zsh)"

# direnv (replaced by programs.direnv in Phase 8)
eval "$(direnv hook zsh)"

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

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Load secrets if exists
[ -f $HOME/.zsh_secrets ] && source $HOME/.zsh_secrets
