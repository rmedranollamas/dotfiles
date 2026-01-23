#!/bin/bash
# -*- mode: sh -*-
# Condiguration of the prompt for bash.

__ps1() {
  if [[ "$(type -t __git_ps1)" == "function" ]] ; then
    __git_ps1 "(Git:%s) "
  fi
}

# Always use colors.
PS1='\[\e[0;34m\]$(__ps1)\[\e[0m\]\[\e[1;34m\]\W\[\e[0m\] \[\e[0;32m\]\$\[\e[0m\] '
PS2='\[\e[0;31m\]>\[\e[0m\] '

precmd_func() {
  history -a
}

precmd_functions+=(precmd_func)
