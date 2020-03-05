# ghq list
alias gh='cd (ghq root)/(ghq list | peco)'

# git
alias g='git'
alias push='git push && git delete-merged-branches'
alias pull='git pull && git delete-merged-branches'

# linux
alias ll='ls -la'

# direnv
direnv hook fish | source

set -x AWS_SDK_LOAD_CONFIG 1
set -x GOPATH $HOME/go
set -x PATH $PATH:$GOPATH/bin
