#!/bin/bash
# -*- mode: sh -*-
# Condiguration of the prompt for bash.

__ps1() {
    __git_ps1 "(Git:%s) "
}

# Always use colors.
PS1='\[\e[0;36m\]\!\[\e[0m\] \[\e[0;34m\]$(__ps1)\[\e[0m\]\[\e[1;37m\]\W\[\e[0m\] \[\e[0;32m\]\$\[\e[0m\] '
PS2='\[\e[0;31m\]>\[\e[0m\] '

# Set the title to user@host.
case "${TERM}" in
    xterm*|rxvt*|screen*)
        PROMPT_COMMAND='history -a && echo -ne "\033]0;${USER}@${HOSTNAME}\007"' ;;
    *)
        PROMPT_COMMAND='history -a' ;;
esac
