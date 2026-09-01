#!/bin/bash
# -*- mode: sh -*-
# Configuration of the prompt for bash.

_update_git_prompt() {
  __git_prompt_str=""
  if declare -F __git_ps1 >/dev/null 2>&1; then
    local saved_ps1="${PS1}"
    __git_ps1 "" "" "(Git:%s) "
    eval "__git_prompt_str=\"${PS1}\""
    PS1="${saved_ps1}"
  fi
}

# Always use colors - all ANSI escapes wrapped in \[...\]
PS1='\[\e[0;34m\]${__git_prompt_str}\[\e[0m\]\[\e[1;34m\]\W\[\e[0m\] \[\e[0;32m\]\$\[\e[0m\] '
PS2='\[\e[0;31m\]>\[\e[0m\] '

precmd_func() {
  history -a
}

_add_precmd_func() {
  local f="$1"
  for existing in "${precmd_functions[@]}"; do
    [[ "$existing" == "$f" ]] && return 0
  done
  precmd_functions+=("$f")
}

_add_precmd_func precmd_func
_add_precmd_func _update_git_prompt
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
