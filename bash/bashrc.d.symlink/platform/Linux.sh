#!/bin/bash
# -*- mode: sh -*-
# Configuration for Linux machines.

if [[ "$OSTYPE" == linux* ]]; then
  # Standard Linux paths
  # Snap
  if [[ -d "/snap/bin" && ":$PATH:" != *":/snap/bin:"* ]]; then
    export PATH="${PATH:+${PATH}:}/snap/bin"
  fi

  # Flatpak
  if [[ -d "/var/lib/flatpak/exports/bin" && ":$PATH:" != *":/var/lib/flatpak/exports/bin:"* ]]; then
    export PATH="${PATH:+${PATH}:}/var/lib/flatpak/exports/bin"
  fi
  if [[ -d "${HOME}/.local/share/flatpak/exports/bin" && ":$PATH:" != *":${HOME}/.local/share/flatpak/exports/bin:"* ]]; then
    export PATH="${PATH:+${PATH}:}${HOME}/.local/share/flatpak/exports/bin"
  fi

  # Linuxbrew
  if [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  elif [[ -x "${HOME}/.linuxbrew/bin/brew" ]]; then
    eval "$("${HOME}/.linuxbrew/bin/brew" shellenv)"
  fi

  # System bash completion (lazy-loaded on first tab press)
  if ! shopt -oq posix && [[ -n "${PS1:-}" || "$-" == *i* ]]; then
    _lazy_bash_completion() {
      complete -r -D 2>/dev/null
      unset -f _lazy_bash_completion
      if [[ -r "/usr/share/bash-completion/bash_completion" ]]; then
        source "/usr/share/bash-completion/bash_completion"
      elif [[ -r "/etc/bash_completion" ]]; then
        source "/etc/bash_completion"
      fi
      if declare -F _comp_complete_load >/dev/null 2>&1; then
        _comp_complete_load "$@"
      elif declare -F _completion_loader >/dev/null 2>&1; then
        _completion_loader "$@"
      fi
      return 124
    }
    if [[ -r "/usr/share/bash-completion/bash_completion" || -r "/etc/bash_completion" ]]; then
      complete -D -F _lazy_bash_completion
    fi
  fi

  # Command-not-found handler fallback
  if [[ "$(type -t command_not_found_handle)" != "function" ]]; then
    if [[ -x "/usr/lib/command-not-found" ]]; then
      command_not_found_handle() {
        /usr/lib/command-not-found -- "$1"
        return $?
      }
    elif [[ -r "/usr/share/command-not-found/command-not-found.sh" ]]; then
      source "/usr/share/command-not-found/command-not-found.sh"
    fi
  fi

  # GPG TTY
  if [[ -t 0 ]]; then
    export GPG_TTY="$(tty 2>/dev/null)"
  fi
fi
