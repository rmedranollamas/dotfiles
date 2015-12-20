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

# Bazel when not using .deb for install.
if [[ -f '/usr/local/lib/bazel/bin/bazel-complete.bash' ]] ; then
  source '/usr/local/lib/bazel/bin/bazel-complete.bash'
fi
