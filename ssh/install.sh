#!/bin/bash

log="${DOTFILES_ROOT}/logs/ssh.install.log"
google_compute_engine="${DOTFILES_ROOT}/ssh/ssh.symlink/google_compute_engine"
sourceforge="${DOTFILES_ROOT}/ssh/ssh.symlink/sourceforge"

if [[ ! -f "${google_compute_engine}" ]] ; then
  ssh-keygen -a 100 -o -t ed25519 -N '' -C "m3drano@$(hostname -f)" -f "${google_compute_engine}" >> "${log}" 2>&1
  chmod 400 "${google_compute_engine}*"
fi

if [[ ! -f "${sourceforge}" ]] ; then
  ssh-keygen -a 100 -o -b 4096 -t rsa -N '' -C 'medranollamas@shell.sf.net' -f "${sourceforge}" >> "${log}" 2>&1
  chmod 400 "${sourceforge}*"
fi

unset sourceforge
unset google_compute_engine
unset log
