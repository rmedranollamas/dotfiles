#!/bin/bash
# -*- mode: sh -*-

log="${DOTFILES_ROOT:-$HOME/dotfiles}/logs/os.install.log"
mkdir -p "$(dirname "$log")"
touch "${log}"

if command -v apt-get &>/dev/null; then
  echo "Updating apt package index..." >> "${log}"
  sudo -n apt-get update -q -y >> "${log}" 2>&1 || true
  packages=(tmux emacs-nox colordiff ripgrep fd-find fzf curl git jq)
  echo "Installing packages with apt-get: ${packages[*]}" >> "${log}"
  sudo -n apt-get install -q -y "${packages[@]}" >> "${log}" 2>&1 || true
elif command -v dnf &>/dev/null; then
  echo "Updating dnf package index..." >> "${log}"
  sudo -n dnf check-update -y >> "${log}" 2>&1 || true
  packages=(tmux emacs-nox colordiff ripgrep fd-find fzf curl git jq)
  echo "Installing packages with dnf: ${packages[*]}" >> "${log}"
  sudo -n dnf install -y "${packages[@]}" >> "${log}" 2>&1 || true
elif command -v pacman &>/dev/null; then
  echo "Updating pacman package index..." >> "${log}"
  sudo -n pacman -Sy --noconfirm >> "${log}" 2>&1 || true
  packages=(tmux emacs-nox colordiff ripgrep fd fzf curl git jq)
  echo "Installing packages with pacman: ${packages[*]}" >> "${log}"
  sudo -n pacman -S --noconfirm --needed "${packages[@]}" >> "${log}" 2>&1 || true
elif command -v apk &>/dev/null; then
  echo "Updating apk package index..." >> "${log}"
  sudo -n apk update >> "${log}" 2>&1 || true
  packages=(tmux emacs-nox colordiff ripgrep fd fzf curl git jq)
  echo "Installing packages with apk: ${packages[*]}" >> "${log}"
  sudo -n apk add "${packages[@]}" >> "${log}" 2>&1 || true
else
  echo "No supported package manager found (apt-get, dnf, pacman, apk)" >> "${log}"
fi

unset log
