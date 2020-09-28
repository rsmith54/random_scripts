
eval "$(lua /usr/bin/z.lua/z.lua --init bash)"

export HISTIGNORE="&:ls:[bf]g:exit"
export HISTFILE="${HOME}/.bash_history"
export HISTFILESIZE=1000000000
export HISTSIZE=1000000000
shopt -s histappend

red=$(tput setaf 1)
#reset=$(tput sgr0)
#RESET=$(tput setaf 0)
PS1='\[$red\][\h] ${PWD} >'
PS1='\[\e[0;31m\][\h]\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[0;31m\]\$ \[\e[m\]\[\e[0;0m\]'
export PS1

export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

set completion-query-items 1000

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

set completion-query-items 1000

set show-all-if-ambiguous on
set show-all-if-unmodified on

alias rm='rm -i'
alias mv='mv -i'
alias where='type -a'
alias ppjson="python -m json.tool"

cd ~/rsmith_home/
