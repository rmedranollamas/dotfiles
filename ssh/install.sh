#!/bin/bash

log="${DOTFILES_ROOT}/logs/ssh.install.log"
github="${DOTFILES_ROOT}/ssh/ssh.symlink/github"
sourceforge="${DOTFILES_ROOT}/ssh/ssh.symlink/sourceforge"

if [[ ! -f "${github}" ]] ; then
  ssh-keygen -a 100 -o -t ed25519 -N '' -C "m3drano@$(hostname -f)" -f "${github}" >> "${log}" 2>&1
  chmod 400 "${github}*"
fi

if [[ ! -f "${sourceforge}" ]] ; then
  ssh-keygen -a 100 -o -b 4096 -t rsa -N '' -C 'medranollamas@shell.sf.net' -f "${sourceforge}" >> "${log}" 2>&1
  chmod 400 "${sourceforge}*"
fi

unset sourceforge
unset github
unset log
