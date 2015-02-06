#!/bin/bash

log="${DOTFILES_ROOT}/logs/os.install.log"
touch "${log}"

# Installs packages in Ubuntu.
packages='tmux emacs24 colordiff python-pip python-virtualenv ipython mosh'
sudo -n sh -c "apt-get install -q -y ${packages} > ${log} 2>&1"

unset log
