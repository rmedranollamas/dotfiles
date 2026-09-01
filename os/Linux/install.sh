#!/bin/bash
# -*- mode: sh -*-

log="${DOTFILES_ROOT:-$HOME/dotfiles}/logs/os.install.log"
mkdir -p "$(dirname "$log")"
touch "${log}"

# Installs packages in Debian / Ubuntu.
if command -v apt-get &>/dev/null; then
  packages=(tmux emacs-nox colordiff ripgrep fd-find fzf curl git jq)
  missing=()
  for pkg in "${packages[@]}"; do
    if ! dpkg -s "$pkg" &>/dev/null; then
      missing+=("$pkg")
    fi
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    sudo -n apt-get update -q -y >> "${log}" 2>&1 || true
    sudo -n apt-get install -q -y "${missing[@]}" >> "${log}" 2>&1 || true
  fi
fi

unset log
