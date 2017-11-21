#!/bin/bash
# -*- mode: sh -*-
#
# Bootstrap script to install the dotfiles.
#
# This script will install the bootfiles by looking into each of the topical
# directories and sourcing the install.sh found there.

# OS X does not have realpath as command.
if [[ "$(uname -s)" == 'Darwin' ]] ; then
  realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
  }
fi

readonly DOTFILES_ROOT="$(dirname `realpath $0`)"
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
  ln -fsn "$1" "$2"
  log_ok "symlink $2 -> $1 created"
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
    sh -c "${file}"
  done
}

system_setup() {
  for file in $(system_files 'install.sh') ; do
    log_sys "seting up ${file}..."
    sh -c "${file}"
  done
}

symlink() {
  for file in $(list_files '*.symlink') ; do
    link_file "$file" "$HOME/.$(basename "${file%.*}")"
  done
}

bootstrap() {
  if [[ $(sudo -v -n &> /dev/null) ]] ; then
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
