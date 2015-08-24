#!/bin/bash
# -*- mode: sh -*-
# Command aliases useful in any environment.

if [[ `ls --color &> /dev/null` ]] ; then
  alias ls='ls --color -hBFG '
else
  alias ls='ls -hBFG '
fi

alias cd..='cd ..'
alias ll='ls -lA '
alias l='ls -log '
alias df='df -hl '
alias du='du -hcxs '
alias e="${EDITOR} "
alias se="sudo ${EDITOR} "
alias g='git '
alias py='python3 '
alias sps='ps -ecmo state,pid,user,%cpu,%mem,command | less'
alias grep='grep --color=auto '
alias emacsserver='emacs --daemon'
alias killemacs="emacsclient -e '(kill-emacs)'"

alias pip-update="pip3 freeze --local | grep -v '^\-e' | cut -d = -f 1 | xargs pip3 install -U"
