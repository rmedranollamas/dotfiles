#!/bin/bash
# -*- mode: sh -*-
# General options for the bash shell.

# Set the proper terminal type.
if [[ -n "${TMUX}" ]] ; then
  export TERM='screen-256color'
else
  export TERM='xterm-256color'
fi

# Stop using Ctrl+S for stopping.
[[ -t 0 ]] && stty stop ""

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize
