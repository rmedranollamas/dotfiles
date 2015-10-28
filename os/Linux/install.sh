#!/bin/bash

log="${DOTFILES_ROOT}/logs/os.install.log"
touch "${log}"

# Installs packages in Debian/Ubuntu.
packages='tmux emacs-nox colordiff'
sudo -n sh -c "apt-get install -q -y ${packages} > ${log} 2>&1"

unset log
