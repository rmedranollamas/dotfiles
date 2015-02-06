#!/bin/bash

log="${DOTFILES_ROOT}/logs/ssh.install.log"
bitbucket="${DOTFILES_ROOT}/ssh/ssh.symlink/bitbucket"

if [[ ! -f "${bitbucket}" ]] ; then
  ssh-keygen -b 4096 -t rsa -N '' -C 'm3drano@gmail.com' -f "${bitbucket}" > "${log}" 2>&1
fi

unset bitbucket
unset log
