#!/bin/bash

if [[ "$(uname -s)" == "Darwin" ]] ; then
  # Autocompletion for Homebrew.
  if [[ -x "$(which brew)" ]] ; then
    brew="$(brew --repository)"
    export PATH="${brew}/bin:${PATH}"
    export LD_LIBRARY_PATH="${brew}/lib:${LD_LIBRARY_PATH}"

    if [[ -d "${brew}/etc/bash_completion.d" ]] ; then
      source_all "${brew}/etc/bash_completion.d"
    fi
  fi
fi

unset brew
