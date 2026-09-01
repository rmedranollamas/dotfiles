#!/bin/bash
set -e

ssh_dir="${HOME}/.ssh"
mkdir -p "${ssh_dir}"
chmod 700 "${ssh_dir}"

log_dir="${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd -P)}/logs"
mkdir -p "${log_dir}"
log="${log_dir}/ssh.install.log"

github="${ssh_dir}/github"
google_compute_engine="${ssh_dir}/google_compute_engine"
sourceforge="${ssh_dir}/sourceforge"

hostname_f="$(hostname -f 2>/dev/null || hostname)"

if [[ ! -f "${github}" ]] ; then
  ssh-keygen -a 100 -o -t ed25519 -N '' -C "rmedranollamas@${hostname_f}" -f "${github}" >> "${log}" 2>&1
fi
if [[ -f "${github}" ]]; then
  chmod 600 "${github}"
fi
if [[ -f "${github}.pub" ]]; then
  chmod 644 "${github}.pub"
fi

if [[ ! -f "${google_compute_engine}" ]] ; then
  ssh-keygen -a 100 -o -t ed25519 -N '' -C "m3drano@${hostname_f}" -f "${google_compute_engine}" >> "${log}" 2>&1
fi
if [[ -f "${google_compute_engine}" ]]; then
  chmod 600 "${google_compute_engine}"
fi
if [[ -f "${google_compute_engine}.pub" ]]; then
  chmod 644 "${google_compute_engine}.pub"
fi

if [[ ! -f "${sourceforge}" ]] ; then
  ssh-keygen -a 100 -o -b 4096 -t rsa -N '' -C 'medranollamas@shell.sf.net' -f "${sourceforge}" >> "${log}" 2>&1
fi
if [[ -f "${sourceforge}" ]]; then
  chmod 600 "${sourceforge}"
fi
if [[ -f "${sourceforge}.pub" ]]; then
  chmod 644 "${sourceforge}.pub"
fi

unset sourceforge google_compute_engine github hostname_f log log_dir ssh_dir
