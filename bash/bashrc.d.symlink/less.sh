#!/bin/bash
# -*- mode:sh -*-
# Some options ta make better use of less

export LESS='-R'

# Make less more friendly for non-text input files, see lesspipe(1).
if [[ -x /usr/bin/lesspipe ]]; then
  export LESSOPEN="| /usr/bin/lesspipe %s"
  export LESSCLOSE="%s"
fi

# Colored man pages using less.
man() {
  env \
    LESS_TERMCAP_mb=$'\e[1;31m' \
    LESS_TERMCAP_md=$'\e[1;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[1;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[1;32m' \
    man "$@"
}
