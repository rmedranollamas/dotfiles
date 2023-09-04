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
if [[ "$(type -t __git_main)" == function ]] ; then
  __git_complete g __git_main
fi
