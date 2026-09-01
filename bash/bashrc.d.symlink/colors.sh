#!/bin/bash
# -*- mode: sh -*-
# Sets colors for the terminal.

export CLICOLOR=yes
export COLORTERM=truecolor

if command -v dircolors >/dev/null 2>&1; then
  dircolors_cache="${XDG_CACHE_HOME:-$HOME/.cache}/dircolors.cache"
  if [[ -r "${HOME}/.dir_colors" ]]; then
    if [[ ! -f "$dircolors_cache" || "${HOME}/.dir_colors" -nt "$dircolors_cache" ]]; then
      mkdir -p "${dircolors_cache%/*}" 2>/dev/null
      dircolors -b "${HOME}/.dir_colors" > "$dircolors_cache" 2>/dev/null
    fi
    if [[ -r "$dircolors_cache" ]]; then
      source "$dircolors_cache"
    else
      eval "$(dircolors -b "${HOME}/.dir_colors")"
    fi
  else
    eval "$(dircolors -b)"
  fi
  unset dircolors_cache
fi
