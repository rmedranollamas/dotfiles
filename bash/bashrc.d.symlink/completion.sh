#!/bin/bash
# -*- mode: sh -*-
# Loads the completion scripts from bashrc.d/completion/

# enable programmable completion features
if [[ -f '/etc/bash_completion' ]] && ! shopt -oq posix; then
      source '/etc/bash_completion'
fi

if [[ -x "$(which brew)" ]] ; then
    brew="$(brew --repository)"
    if [[ -d "${brew}/etc/bash_completion.d" ]] && ! shopt -oq posix; then
	source_all "${brew}/etc/bash_completion.d"
    fi
    unset brew
fi

# Go over all the possible completion scripts available.
source_all "${BASHRCD}/completion"
