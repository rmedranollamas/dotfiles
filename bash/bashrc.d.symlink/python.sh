#!/bin/bash
# -*- mode:sh -*-
# Python REPL configuration.

export PYTHONSTARTUP="${HOME}/.pythonrc"

# Created by `pipx`
export PATH="/Users/ramon/.local/bin${PATH+:$PATH}"

if [[ $(type -P 'pipenv') ]]; then
  eval "$(_PIPENV_COMPLETE=bash_source pipenv)"
fi

alias pip-update="pip3 freeze --local | grep -v '^\-e' | cut -d = -f 1 | xargs pip3 install -U"
