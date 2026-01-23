#!/bin/bash
# -*- mode: sh -*-
# Loads the completion scripts from bashrc.d/completion/

# enable programmable completion features
if [[ -f '/etc/bash_completion' ]] && ! shopt -oq posix; then
  source '/etc/bash_completion'
fi

# Use ~/.bashrc.d as the base.
COMP_DIR="${HOME}/.bashrc.d/completion"

# Always source git-prompt as it is needed for the prompt.
if [[ -f "${COMP_DIR}/git-prompt.bash" ]]; then
  source "${COMP_DIR}/git-prompt.bash"
elif [[ -f "${COMP_DIR}/git-prompt.sh" ]]; then
  source "${COMP_DIR}/git-prompt.sh"
fi

# Lazy load git completion.
_git_completion_setup() {
  local completion_script="${HOME}/.bashrc.d/completion/git.bash"
  if [[ ! -f "$completion_script" ]]; then
    completion_script="${HOME}/.bashrc.d/completion/git-completion.bash"
  fi

  if [[ -f "$completion_script" ]]; then
    source "$completion_script"

    # Initialize completion variables if they are not set.
    if type _get_comp_words_by_ref &>/dev/null; then
      _get_comp_words_by_ref -n =: cur words cword prev
    else
      local cur="${COMP_WORDS[COMP_CWORD]}"
      local prev="${COMP_WORDS[COMP_CWORD-1]}"
      local words=("${COMP_WORDS[@]}")
      local cword="$COMP_CWORD"
    fi

    # Initialize __git_cmd_idx to avoid unary operator errors in some versions of git-completion.
    local __git_cmd_idx=0

    if type __git_complete &>/dev/null; then
      __git_complete g git
    elif [[ "$(type -t _git)" == "function" ]]; then
      complete -o bashdefault -o default -o nospace -F _git g 2>/dev/null \
        || complete -o default -o nospace -F _git g
    fi

    # Trigger completion for the current tab press.
    if [[ "$(type -t _git)" == "function" ]]; then
      _git
    elif [[ "$(type -t __git_main)" == "function" ]]; then
      __git_main
    fi
  fi
}

# Load other completion scripts.
if [[ -f "${COMP_DIR}/Darwin.sh" ]]; then
  source "${COMP_DIR}/Darwin.sh"
fi

# Some handy overrides.
if [[ -f "${COMP_DIR}/git.bash" || -f "${COMP_DIR}/git-completion.bash" ]]; then
  complete -F _git_completion_setup g git
fi
