#!/bin/bash
# -*- mode: sh -*-
# Specifics for OS X / macOS.

if [[ "$OSTYPE" == darwin* ]] ; then
  export PATH="/usr/local/sbin${PATH+:$PATH}"

  # Dynamic Homebrew prefix detection
  brew_bin=""
  if [[ -x "/opt/homebrew/bin/brew" ]]; then
    brew_bin="/opt/homebrew/bin/brew"
  elif [[ -x "/usr/local/bin/brew" ]]; then
    brew_bin="/usr/local/bin/brew"
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

    export HOMEBREW_NO_ANALYTICS=1
    export HOMEBREW_NO_AUTO_UPDATE=1
    export HOMEBREW_NO_EMOJI=1
    export HOMEBREW_NO_INSTALL_CLEANUP=1

    brew_prefix="${HOMEBREW_PREFIX:-${brew_bin%/bin/brew}}"
    if [[ -n "$brew_prefix" ]]; then
      if [[ -d "${brew_prefix}/opt/openblas" ]]; then
        export OPENBLAS="${brew_prefix}/opt/openblas"
      fi
    fi
  fi
  unset brew_bin brew_prefix

  if [[ -d "/Applications/Emacs.app/Contents/MacOS/bin" ]]; then
    export PATH="/Applications/Emacs.app/Contents/MacOS/bin${PATH+:$PATH}"
  fi

  if [[ -t 0 ]]; then
    export GPG_TTY="$(tty 2>/dev/null)"
  fi

  if [[ -d "${HOME}/Library/Android/sdk" ]]; then
    export ANDROID_HOME="${HOME}/Library/Android/sdk"
    export PATH="${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools"
  fi
fi
