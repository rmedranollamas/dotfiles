#!/bin/bash
# -*- mode:sh -*-
# Python REPL configuration.

# Configuration for the Python interpreter.
export PYTHONSTARTUP="${HOME}/.pythonrc"

export PYENV_ROOT="${HOME}/.pyenv"
export PATH="${PYENV_ROOT}/bin:${PATH}"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
eval "$(pyenv virtualenvwrapper_lazy -)"
export PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV='true'

# virtualenvwrapper and virtualenv.
export PIP_REQUIRE_VIRTUALENV='true'
export WORKON_HOME="${HOME}/.pyenv/versions"
