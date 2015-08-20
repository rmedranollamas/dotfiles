#!/bin/bash

log="${DOTFILES_ROOT}/logs/os.install.log"
touch "${log}"

# Installs packages in Debian.
packages='tmux emacs-nox colordiff python3 python3-pip python3-virtualenv virtualenv'
sudo -n sh -c "apt-get install -q -y ${packages} > ${log} 2>&1"

unset log
