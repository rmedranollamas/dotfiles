#!/bin/bash
# -*- mode:sh -*-
# Python REPL configuration.

export PYTHONSTARTUP="${HOME}/.pythonrc"
export PYENV_ROOT="${HOME}/.pyenv"
export PATH="${PYENV_ROOT}/bin:${PATH}"
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
export WORKON_HOME="${HOME}/.pyenv/versions"

eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
