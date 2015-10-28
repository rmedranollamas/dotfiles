#!/bin/bash
# -*- mode: sh -*-
# Sets colors for the terminal.

export CLICOLOR=yes

if [[ -x "$(which dircolors)" ]]; then
  [[ -r "${HOME}/.dir_colors" ]] && eval "$(dircolors -b ~/.dir_colors)"
fi
