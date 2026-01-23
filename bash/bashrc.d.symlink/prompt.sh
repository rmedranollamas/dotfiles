#!/bin/bash
# -*- mode: sh -*-
# Condiguration of the prompt for bash.

__ps1() {
  if [[ -n "${G3_CLIENT_NAME}" ]] ; then
    echo -n "(${G3_CLIENT_NAME}) "
  elif [[ "$(type -t __git_ps1)" == "function" ]] ; then
    __git_ps1 "(Git:%s) "
  fi
}

# Always use colors.
PS1='\[\e[0;34m\]$(__ps1)\[\e[0m\]\[\e[1;34m\]\W\[\e[0m\] \[\e[0;32m\]\$\[\e[0m\] '
PS2='\[\e[0;31m\]>\[\e[0m\] '

__set_g3_vars() {
  G3_CLIENT_NAME=""
  if [[ -f "${PWD}/METADATA" ]] ; then
    G3_CLIENT_NAME=$(basename `pwd`)
  fi
}

precmd_func() {
  history -a
  __set_g3_vars
}

precmd_functions+=(precmd_func)

_run_precmd_functions() {
  local f
  for f in "${precmd_functions[@]}"; do
    "$f"
  done
}

PROMPT_COMMAND="_run_precmd_functions"
