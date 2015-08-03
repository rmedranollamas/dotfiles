#!/bin/bash
# -*- mode: sh -*-
# Miscelaneus.

# Easier cd for the Home folders.
CDPATH=':~'

# Export the GPG_TTY variable and the agent location.
if [[ "$(uname -s)" == 'Darwin' ]]; then
  if [ -f "${HOME}/.gpg-agent-info" ]; then
    source  "${HOME}/.gpg-agent-info"
    export GPG_AGENT_INFO
  fi
fi

GPG_TTY="$(tty)"
export GPG_TTY
