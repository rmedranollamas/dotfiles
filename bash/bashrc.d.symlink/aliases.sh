#!/bin/bash
# -*- mode: sh -*-
# Command aliases useful in any environment.

export LS_OPTIONS='-hBF'
if [[ `ls --color &> /dev/null` ]] ; then
  export LS_OPTIONS="${LS_OPTIONS} --color=yes"
fi

alias ls="ls ${LS_OPTIONS}"
alias cd..='cd ..'
alias ll='ls -oA '
alias l='ls -og '
alias df='df -hl '
alias du='du -hcxs '
alias e="${EDITOR} "
alias se="sudo ${EDITOR} "
alias g='git '
alias py='python '
alias sps='ps -ecmo state,pid,user,%cpu,%mem,command | less'
alias grep='grep --color=auto '
alias emacsserver='emacs --daemon'
alias killemacs="emacsclient -e '(kill-emacs)'"

alias pip-update="pip freeze --local | grep -v '^\-e' | cut -d = -f 1 | xargs pip install -U"
