#!/bin/bash
# -*- mode: sh -*-
# Specifics for bash completion in OS X.

if [[ "$(uname -s)" == "Darwin" ]] ; then
  if [[ -x "$(which brew)" ]] ; then
    brew="$(brew --prefix)"
    if [[ -f "${brew}/etc/bash_completion" ]] ; then
      source "${brew}/etc/bash_completion"
    fi
    unset brew
  fi
fi
