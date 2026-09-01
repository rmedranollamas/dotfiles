#!/bin/bash
# -*- mode: sh -*-
# Loads git completion and prompt from system or local fallbacks

COMP_DIR="${HOME}/.bashrc.d/completion"

# Always source git-prompt eagerly as it is needed for the prompt.
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

# Lazy-load system programmable completion and configure Git completion on first completion request
if ! shopt -oq posix; then
  _lazy_bash_completion() {
    # Remove lazy completion handler to avoid recursive loops
    complete -r -D 2>/dev/null
    unset -f _lazy_bash_completion

    # Load system bash completion
    if [[ -r '/usr/share/bash-completion/bash_completion' ]]; then
      source '/usr/share/bash-completion/bash_completion'
    elif [[ -r '/etc/bash_completion' ]]; then
      source '/etc/bash_completion'
    elif [[ -n "${HOMEBREW_PREFIX:-}" && -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
      source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
    elif [[ -n "${HOMEBREW_PREFIX:-}" && -r "${HOMEBREW_PREFIX}/share/bash-completion/bash_completion" ]]; then
      source "${HOMEBREW_PREFIX}/share/bash-completion/bash_completion"
    elif [[ -r '/opt/homebrew/etc/profile.d/bash_completion.sh' ]]; then
      source '/opt/homebrew/etc/profile.d/bash_completion.sh'
    elif [[ -r '/usr/local/etc/profile.d/bash_completion.sh' ]]; then
      source '/usr/local/etc/profile.d/bash_completion.sh'
    elif [[ -r '/home/linuxbrew/.linuxbrew/etc/profile.d/bash_completion.sh' ]]; then
      source '/home/linuxbrew/.linuxbrew/etc/profile.d/bash_completion.sh'
    elif [[ -r "${HOME}/.linuxbrew/etc/profile.d/bash_completion.sh" ]]; then
      source "${HOME}/.linuxbrew/etc/profile.d/bash_completion.sh"
    fi

    # Trigger dynamic completion loader for the requested command
    if declare -F _comp_complete_load >/dev/null 2>&1; then
      _comp_complete_load "$@"
    elif declare -F _completion_loader >/dev/null 2>&1; then
      _completion_loader "$@"
    fi

    # Configure alias 'g' for git completion
    if declare -F __git_complete >/dev/null 2>&1; then
      __git_complete g git 2>/dev/null || true
    elif declare -F _git >/dev/null 2>&1; then
      complete -o bashdefault -o default -o nospace -F _git g 2>/dev/null \
        || complete -o default -o nospace -F _git g 2>/dev/null || true
    fi

    return 124
  }

  complete -D -F _lazy_bash_completion
fi
