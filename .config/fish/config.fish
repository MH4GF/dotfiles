# ghq list
alias gh='cd (ghq root)/(ghq list | peco)'

# git
alias g='git'
alias push='git push && git delete-merged-branches'
alias pull='git pull && git delete-merged-branches'
alias rebase='git fetch && git pull --rebase origin develop'

# linux
alias ll='ls -la'

# aws-cli
alias aws='docker run --rm -it -v "$HOME/.aws:/root/.aws" mesosphere/aws-cli'
