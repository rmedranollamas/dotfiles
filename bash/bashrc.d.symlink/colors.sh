#!/bin/bash
# -*- mode: sh -*-
# Sets colors for the terminal.

export CLICOLOR=yes

if [[ -x `which dircolors` ]]; then
  [[ -r "${HOME}/.dircolors" ]] && eval "$(dircolors -b ~/.dircolors)"
fi
