#!/bin/bash

if [[ "$(uname -s)" == "Darwin" ]] ; then
  if [[ -x "$(which brew)" ]] ; then
    brew="$(brew --prefix)"
    if [[ -f "${brew}/etc/bash_completion" ]] ; then
      source "${brew}/etc/bash_completion"
    fi
    unset brew
  fi
fi
