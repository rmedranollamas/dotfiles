#!/bin/bash
# -*- mode: sh -*-
# Specifics for OS X.

if [[ "$(uname -s)" == "Darwin" ]] ; then
  export DISPLAY=':0.0'
  export HOMEBREW_NO_ANALYTICS=1

  if [[ -d "${HOME}/Library/Android/sdk" ]] ; then
    export ANDROID_HOME="${HOME}/Library/Android/sdk"
    export PATH="${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${PATH}"
  fi

  if [[ -d "/usr/local/opt/go/libexec/bin" ]] ; then
    export PATH="${PATH}:/usr/local/opt/go/libexec/bin"
  fi

  if [[ -f "${HOME}/.gnupg/gpg-agent-info" ]]; then
    source "${HOME}/.gnupg/gpg-agent-info"
    export GPG_AGENT_INFO
    export GPG_TTY="$(tty)"
  fi

  # iTerm 2 integration.
  if [[ -e "${HOME}/.iterm2_shell_integration.bash" ]] ; then
    source "${HOME}/.iterm2_shell_integration.bash"
  fi
fi
