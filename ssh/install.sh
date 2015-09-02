#!/bin/bash

log="${DOTFILES_ROOT}/logs/ssh.install.log"
bitbucket="${DOTFILES_ROOT}/ssh/ssh.symlink/bitbucket"
sourceforge="${DOTFILES_ROOT}/ssh/ssh.symlink/sourceforge"

if [[ ! -f "${bitbucket}" ]] ; then
  ssh-keygen -a 1000 -o -b 4096 -t rsa -N '' -C 'm3drano@gmail.com' -f "${bitbucket}" > "${log}" 2>&1
  chmod 400 "${bitbucket}*"
fi

if [[ ! -f "${sourceforge}" ]] ; then
  ssh-keygen -t dsa -N '' -C 'medranollamas@shell.sf.net' -f "${sourceforge}" >> "${log}" 2>&1
  chmod 400 "${sourceforge}*"
fi

unset sourceforge
unset bitbucket
unset log
