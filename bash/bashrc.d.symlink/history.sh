#!/bin/bash
# -*- mode: sh -*-
# Options governing the shell command history, mostly for bash.

# Append to the history file, don't overwrite it.
shopt -s cmdhist
shopt -s histappend

# Don't put duplicate lines or lines starting with spaces in the history and
# use a sane date format.
export HISTCONTROL='ignoreboth'
export HISTTIMEFORMAT='%d/%m/%Y %T - '
export HISTSIZE=1000000
export HISTFILESIZE=1000000000
