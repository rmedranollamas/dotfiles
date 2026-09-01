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
export PATH="${PATH}:${DOTFILES_ROOT}/bin"

# Make bash exit if some command does not return 0.
set -e

log_info () {
  printf "\r\033[2K  [\033[00;34mINFO\033[0m] %s\n" "$1"
}

log_ok () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] %s\n" "$1"
}

log_sys () {
  printf "\r\033[2K  [ \033[0;31mOS\033[0m ] %s\n" "$1"
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

setup_directories() {
  local dir
  for dir in "${HOME}/.ssh" "${HOME}/.saves" "${HOME}/.emacs.d/auto-saves"; do
    if [[ ! -d "${dir}" ]]; then
      mkdir -p "${dir}"
    fi
    chmod 700 "${dir}"
  done
}

setup_ssh() {
  local ssh_dir="${HOME}/.ssh"
  local ssh_config_src="${DOTFILES_ROOT}/ssh/config"
  local ssh_config_dest="${ssh_dir}/config"

  if [[ -L "${ssh_dir}" ]]; then
    log_info "Unlinking symlinked ${ssh_dir}"
    rm -f "${ssh_dir}"
  fi

  mkdir -p "${ssh_dir}"
  chmod 700 "${ssh_dir}"

  if [[ -f "${ssh_config_src}" ]]; then
    link_file "${ssh_config_src}" "${ssh_config_dest}"
    chmod 600 "${ssh_config_src}" 2>/dev/null || true
    chmod 600 "${ssh_config_dest}" 2>/dev/null || true
  fi
}

install() {
  while IFS= read -r -d '' file; do
    log_info "running ${file}..."
    bash "${file}"
  done < <(find "${DOTFILES_ROOT}" -maxdepth 2 -name 'install.sh' -print0)
}

system_setup() {
  local sys_name
  sys_name="$(uname -s)"
  while IFS= read -r -d '' file; do
    log_sys "setting up ${file}..."
    bash "${file}"
  done < <(find "${DOTFILES_ROOT}" -maxdepth 3 -name 'install.sh' -path "*/${sys_name}/*" -print0)
}

symlink() {
  while IFS= read -r -d '' file; do
    link_file "${file}" "${HOME}/.$(basename "${file%.*}")"
  done < <(find "${DOTFILES_ROOT}" -maxdepth 2 -name '*.symlink' -print0)
}

bootstrap() {
  if sudo -n -v &>/dev/null; then
    log_ok 'sudo credentials renewed'
  fi
  setup_directories
  setup_ssh
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
