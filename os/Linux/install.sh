#!/bin/bash
# -*- mode: sh -*-

log="${DOTFILES_ROOT:-$HOME/dotfiles}/logs/os.install.log"
mkdir -p "$(dirname "$log")"
touch "${log}"

# Installs packages in Debian / Ubuntu.
if command -v apt-get &>/dev/null; then
  packages=(tmux emacs-nox colordiff ripgrep fd-find fzf curl git jq)
  sudo -n apt-get update -q -y >> "${log}" 2>&1 || true
  sudo -n apt-get install -q -y "${packages[@]}" >> "${log}" 2>&1 || true
fi

unset log
