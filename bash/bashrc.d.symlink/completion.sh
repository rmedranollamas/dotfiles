#!/bin/bash
# -*- mode: sh -*-
# Loads git completion and prompt from system or local fallbacks

# Enable programmable completion features
if ! shopt -oq posix; then
  if [[ -f '/usr/share/bash-completion/bash_completion' ]]; then
    source '/usr/share/bash-completion/bash_completion'
  elif [[ -f '/etc/bash_completion' ]]; then
    source '/etc/bash_completion'
  elif [[ -f '/opt/homebrew/etc/profile.d/bash_completion.sh' ]]; then
    source '/opt/homebrew/etc/profile.d/bash_completion.sh'
  elif [[ -f '/usr/local/etc/profile.d/bash_completion.sh' ]]; then
    source '/usr/local/etc/profile.d/bash_completion.sh'
  fi
fi

COMP_DIR="${HOME}/.bashrc.d/completion"

# Always source git-prompt as it is needed for the prompt.
if [[ -f '/usr/lib/git-core/git-sh-prompt' ]]; then
  source '/usr/lib/git-core/git-sh-prompt'
elif [[ -f '/usr/share/git-core/contrib/completion/git-prompt.sh' ]]; then
  source '/usr/share/git-core/contrib/completion/git-prompt.sh'
elif [[ -f '/opt/homebrew/etc/bash_completion.d/git-prompt.sh' ]]; then
  source '/opt/homebrew/etc/bash_completion.d/git-prompt.sh'
elif [[ -f '/usr/local/etc/bash_completion.d/git-prompt.sh' ]]; then
  source '/usr/local/etc/bash_completion.d/git-prompt.sh'
elif [[ -f "${COMP_DIR}/git-prompt.bash" ]]; then
  source "${COMP_DIR}/git-prompt.bash"
elif [[ -f "${COMP_DIR}/git-prompt.sh" ]]; then
  source "${COMP_DIR}/git-prompt.sh"
fi

# Load git completion from native system bash-completion loader and configure alias 'g'
_git_completion_setup() {
  if ! type __git_complete &>/dev/null; then
    if type _comp_load &>/dev/null; then
      _comp_load git 2>/dev/null || true
    elif type _completion_loader &>/dev/null; then
      _completion_loader git 2>/dev/null || true
    fi
  fi

  if type __git_complete &>/dev/null; then
    __git_complete g git
  elif [[ "$(type -t _git)" == "function" ]]; then
    complete -o bashdefault -o default -o nospace -F _git g 2>/dev/null \
      || complete -o default -o nospace -F _git g
  fi
}

_git_completion_setup
