#!/bin/bash
# -*- mode:sh -*-
# Python REPL configuration.

export PYTHONSTARTUP="${HOME}/.pythonrc"

# Created by `pipx`
if [[ -d "${HOME}/.local/bin" ]]; then
  export PATH="${HOME}/.local/bin:${PATH}"
fi

# Lazy load pipenv completion
if [[ $(type -P 'pipenv') ]]; then
  _pipenv_completion() {
    eval "$(_PIPENV_COMPLETE=bash_source pipenv)"
    complete -F _pipenv_completion pipenv
  }
  complete -F _pipenv_completion pipenv
fi

alias pip-update="pip3 freeze --local | grep -v '^\-e' | cut -d = -f 1 | xargs pip3 install -U"
