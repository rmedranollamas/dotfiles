#!/bin/bash
# -*- mode: sh -*-
# Specifics for OS X.

if [[ "$(uname -s)" == "Darwin" ]] ; then
  export PATH="/usr/local/sbin${PATH+:$PATH}"
  export DISPLAY=':0.0'

  if [[ -x "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
    export HOMEBREW_NO_ANALYTICS=1
    export HOMEBREW_NO_AUTO_UPDATE=1
    export HOMEBREW_NO_EMOJI=1
    export HOMEBREW_NO_INSTALL_CLEANUP=1
  fi

  if [[ -d "/Applications/Emacs.app/Contents/MacOS/bin" ]]; then
    export PATH="/Applications/Emacs.app/Contents/MacOS/bin${PATH+:$PATH}";
    alias emacs='/Applications/Emacs.app/Contents/MacOS/Emacs.sh'
  fi

  if [[ -f "${HOME}/.gnupg/gpg-agent-info" ]]; then
    source "${HOME}/.gnupg/gpg-agent-info"
    export GPG_AGENT_INFO
    export GPG_TTY="$(tty)"
  fi
fi
