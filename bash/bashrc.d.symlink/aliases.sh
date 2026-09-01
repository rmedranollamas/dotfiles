#!/bin/bash
# -*- mode: sh -*-
# Command aliases useful in any environment.

# Modern CLI tool fallbacks for ls/tree
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first'
  alias l='eza -l --group-directories-first'
  alias ll='eza -la --group-directories-first'
  alias tree='eza --tree'
elif command -v lsd >/dev/null 2>&1; then
  alias ls='lsd --group-dirs first'
  alias l='lsd -l --group-dirs first'
  alias ll='lsd -la --group-dirs first'
  alias tree='lsd --tree'
else
  if [[ "$OSTYPE" == darwin* ]]; then
    export CLICOLOR=1
    alias ls='ls -GFh'
  else
    alias ls='ls -Fh --color=auto'
  fi
  alias l='ls -l'
  alias ll='ls -lA'
fi

# Modern CLI tool fallbacks for cat
if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never'
  alias preview='bat'
elif command -v batcat >/dev/null 2>&1; then
  alias bat='batcat'
  alias cat='batcat --paging=never'
  alias preview='batcat'
fi

# Safe interactive file flags
alias cp='cp -i'
alias mv='mv -i'
if [[ "$OSTYPE" == darwin* ]]; then
  alias rm='rm -i'
else
  alias rm='rm -I'
fi
alias mkdir='mkdir -pv'

# Navigation and system aliases
alias cd..='cd ..'
alias df='df -h'
alias du='du -h'
alias sps='ps aux | less'
alias grep='grep --color=auto --exclude-dir={.git,.hg,.svn,node_modules}'

# Lazy evaluation of EDITOR
alias e='${EDITOR:-nano}'
alias se='sudo -E ${EDITOR:-nano}'

# Development and helper aliases
alias g='git '
alias py='python3'
alias emacsserver='emacs --daemon'
alias killemacs="emacsclient -e '(kill-emacs)'"
