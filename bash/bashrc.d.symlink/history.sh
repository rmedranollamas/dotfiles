#!/bin/bash
# -*- mode: sh -*-
# Options governing the shell command history, mostly for bash.

# Append to the history file, don't overwrite it.
shopt -s cmdhist
shopt -s histappend

# Don't put duplicate lines or lines starting with spaces in the history and
# use a sane date format.
HISTCONTROL='ignoreboth'
HISTTIMEFORMAT='%d/%m/%Y %T - '
HISTSIZE=64000
HISTFILESIZE=64000
