#!/bin/bash
# -*- mode: sh -*-
# Specifics for OS X.

if [[ "$(uname -s)" == "Darwin" ]] ; then
  export PATH="/usr/local/sbin:${PATH}"
  export DISPLAY=':0.0'
  export HOMEBREW_NO_ANALYTICS=1
  export HOMEBREW_NO_AUTO_UPDATE=1
  export HOMEBREW_NO_EMOJI=1

  if brew command command-not-found-init > /dev/null 2>&1; then
    eval "$(brew command-not-found-init)"
  fi

  if [[ -d "${HOME}/Library/Android/sdk" ]] ; then
    export ANDROID_HOME="${HOME}/Library/Android/sdk"
    export PATH="${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools"
  fi

  if [[ -d "/usr/local/opt/go/libexec/bin" ]] ; then
    export PATH="${PATH}:/usr/local/opt/go/libexec/bin"
  fi

  if [[ -f "${HOME}/.gnupg/gpg-agent-info" ]]; then
    source "${HOME}/.gnupg/gpg-agent-info"
    export GPG_AGENT_INFO
    export GPG_TTY="$(tty)"
  fi
fi
