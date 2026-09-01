#!/bin/bash
# -*- mode: sh -*-
# Configuration of the prompt for bash.

__ps1() {
  if [[ -n "${G3_CLIENT_NAME}" ]]; then
    echo -n "(${G3_CLIENT_NAME}) "
  elif [[ "$(type -t __git_ps1)" == "function" ]]; then
    __git_ps1 "(Git:%s) "
  fi
}

# Always use colors - all ANSI escapes wrapped in \[...\]
PS1='\[\e[0;34m\]$(__ps1)\[\e[0m\]\[\e[1;34m\]\W\[\e[0m\] \[\e[0;32m\]\$\[\e[0m\] '
PS2='\[\e[0;31m\]>\[\e[0m\] '

__set_g3_vars() {
  G3_CLIENT_NAME=""
  if [[ -f "${PWD}/METADATA" ]]; then
    G3_CLIENT_NAME="${PWD##*/}"
  fi
}

precmd_func() {
  history -a
  __set_g3_vars
}

_add_precmd_func() {
  local f="$1"
  for existing in "${precmd_functions[@]}"; do
    [[ "$existing" == "$f" ]] && return 0
  done
  precmd_functions+=("$f")
}

_add_precmd_func precmd_func
unset -f _add_precmd_func

_run_precmd_functions() {
  local f
  for f in "${precmd_functions[@]}"; do
    "$f"
  done
}

case ";${PROMPT_COMMAND};" in
  *";_run_precmd_functions;"*) ;;
  *)
    if [[ -z "${PROMPT_COMMAND}" ]]; then
      PROMPT_COMMAND="_run_precmd_functions"
    else
      PROMPT_COMMAND="${PROMPT_COMMAND};_run_precmd_functions"
    fi
    ;;
esac
