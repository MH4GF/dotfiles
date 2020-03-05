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

# direnv
direnv hook fish | source

set -x AWS_SDK_LOAD_CONFIG 1
set -x GOPATH $HOME/go
set -x PATH $PATH:$GOPATH/bin
