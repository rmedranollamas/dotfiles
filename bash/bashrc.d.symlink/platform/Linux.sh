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

  # Linuxbrew with mtime-checked shellenv cache
  brew_bin=""
  if [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    brew_bin="/home/linuxbrew/.linuxbrew/bin/brew"
  elif [[ -x "${HOME}/.linuxbrew/bin/brew" ]]; then
    brew_bin="${HOME}/.linuxbrew/bin/brew"
  elif command -v brew &>/dev/null; then
    brew_bin="$(command -v brew)"
  fi

  if [[ -n "$brew_bin" ]]; then
    brew_cache="${XDG_CACHE_HOME:-$HOME/.cache}/brew_shellenv.cache"
    if [[ ! -f "$brew_cache" || "$brew_bin" -nt "$brew_cache" ]]; then
      mkdir -p "${brew_cache%/*}" 2>/dev/null
      "$brew_bin" shellenv > "$brew_cache" 2>/dev/null
    fi
    if [[ -r "$brew_cache" ]]; then
      source "$brew_cache"
    else
      eval "$("$brew_bin" shellenv)"
    fi
    unset brew_cache
  fi
  unset brew_bin

  # Command-not-found handler fallback
  if ! declare -F command_not_found_handle >/dev/null 2>&1; then
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
