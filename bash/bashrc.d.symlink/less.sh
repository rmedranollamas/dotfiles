#!/bin/bash
# -*- mode:sh -*-
# Some options ta make better use of less

export LESS='-R'

# Make less more friendly for non-text input files, see lesspipe(1).
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/bash lesspipe)"

# Colored man pages using less.
man() {
    env \
        LESS_TERMCAP_mb=$(printf "\e[1;31m") \
        LESS_TERMCAP_md=$(printf "\e[1;31m") \
        LESS_TERMCAP_me=$(printf "\e[0m") \
        LESS_TERMCAP_se=$(printf "\e[0m") \
        LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
        LESS_TERMCAP_ue=$(printf "\e[0m") \
        LESS_TERMCAP_us=$(printf "\e[1;32m") \
        man "$@"
}
