#!/bin/bash
# -*- mode: sh -*-
#
# Bootstrap script to install the dotfiles.
#
# This script will install the bootfiles by looking into each of the topical
# directories and sourcing the install.sh found there.

readonly DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd -P)"
export DOTFILES_ROOT

# Create a logs dir.
mkdir -p "${DOTFILES_ROOT}/logs"

# Use first system tools, since those in bin might have dependencies.
export PATH=${PATH}:${DOTFILES_ROOT}/bin

# Make bash exit if some command does not return 0.
set -e

log_info () {
  printf "\r\033[2K  [\033[00;34mINFO\033[0m] $1\n"
}

log_ok () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

log_sys () {
  printf "\r\033[2K  [ \033[0;31mOS\033[0m ] $1\n"
}

link_file() {
  local src="$1"
  local dest="$2"

  if [[ -L "$dest" ]] && [[ "$(readlink -f "$dest" 2>/dev/null || readlink "$dest" 2>/dev/null)" == "$(readlink -f "$src" 2>/dev/null || echo "$src")" ]]; then
    log_ok "$dest already points to $src"
    return
  fi

  if [[ -e "$dest" || -L "$dest" ]]; then
    log_info "Backing up $dest to $dest.bak"
    mv "$dest" "$dest.bak"
  fi

  ln -sfn "$src" "$dest"
  log_ok "symlink $dest -> $src created"
}

list_files() {
  find "${DOTFILES_ROOT}" -maxdepth 2 -name "$1"
}

system_files() {
  find "${DOTFILES_ROOT}" -maxdepth 3 -name "$1" -regex ".*/$(uname -s)/.*"
}

install() {
  for file in $(list_files 'install.sh') ; do
    log_info "running ${file}..."
    bash "${file}"
  done
}

system_setup() {
  for file in $(system_files 'install.sh') ; do
    log_sys "setting up ${file}..."
    bash "${file}"
  done
}

symlink() {
  for file in $(list_files '*.symlink') ; do
    link_file "$file" "$HOME/.$(basename "${file%.*}")"
  done
}

bootstrap() {
  if sudo -n -v &>/dev/null; then
    log_ok 'sudo credentials renewed'
  fi
  system_setup
  echo ''
  link_file "${DOTFILES_ROOT}/bin" "${HOME}/.bin"
  echo ''
  install
  echo ''
  symlink
}


echo ''

bootstrap

echo ''
