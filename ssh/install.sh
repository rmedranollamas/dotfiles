#!/bin/bash

log="${DOTFILES_ROOT}/logs/ssh.install.log"
gce="${DOTFILES_ROOT}/ssh/ssh.symlink/gce"
sourceforge="${DOTFILES_ROOT}/ssh/ssh.symlink/sourceforge"

if [[ ! -f "${gce}" ]] ; then
  ssh-keygen -a 100 -o -t ed25519 -N '' -C "m3drano@$(hostname -f)" -f "${gce}" >> "${log}" 2>&1
  chmod 400 "${gce}*"
fi

if [[ ! -f "${sourceforge}" ]] ; then
  ssh-keygen -a 100 -o -b 4096 -t rsa -N '' -C 'medranollamas@shell.sf.net' -f "${sourceforge}" >> "${log}" 2>&1
  chmod 400 "${sourceforge}*"
fi

unset sourceforge
unset gce
unset log
