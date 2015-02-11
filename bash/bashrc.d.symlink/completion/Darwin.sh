#!/bin/bash

if [[ "$(uname -s)" == "Darwin" ]] ; then
  # Autocompletion for Homebrew.
  if [[ -x "$(which brew)" ]] ; then
    brew="$(brew --prefix)"

    if [[ -f "${brew}/etc/bash_completion" ]] ; then
      source "${brew}/etc/bash_completion"
    fi
  fi
fi

unset brew
