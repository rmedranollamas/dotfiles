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
complete -o bashdefault -o default -o nospace -F _git g 2>/dev/null \
    || complete -o default -o nospace -F _git g
