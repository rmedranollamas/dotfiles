#!/bin/bash
# -*- mode: sh -*-
# Loads the completion scripts from bashrc.d/completion/

# enable programmable completion features
if [[ -f '/etc/bash_completion' ]] && ! shopt -oq posix; then
  source '/etc/bash_completion'
fi

# Go over all the possible completion scripts locally available.
source_all "${BASHRCD}/completion"

# Some handy overrides.
if [[ -n "$(type -t _completion_loader)" ]] ; then
  _completion_loader git
fi
if [[ -n "$(type -t _git)" ]] ; then
  __git_complete g _git
fi

if [[ -x "$(which kubectl)" ]] ; then
  source <(kubectl completion bash)
  alias k='kubectl'
  complete -F __start_kubectl k
fi

if [[ -x "$(which brew)" ]] ; then
  if [[ -f "$(brew --prefix)/etc/bash_completion" ]]; then
    source "$(brew --prefix)/etc/bash_completion"
  fi
fi
