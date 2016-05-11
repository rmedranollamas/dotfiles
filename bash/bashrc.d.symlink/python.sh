#!/bin/bash
# -*- mode:sh -*-
# Python REPL configuration.

# Configuration for the Python interpreter.
export PYTHONSTARTUP="${HOME}/.pythonrc"

# virtualenvwrapper and virtualenv.
export PIP_REQUIRE_VIRTUALENV='true'
export VIRTUALENV_PYTHON="$(which python3)"
export WORKON_HOME="${HOME}/Code/.virtualenvs"

# virtualenvwrapper config for Homebrew.
if [[ -f "$(which virtualenvwrapper_lazy.sh)" ]] ; then
  export VIRTUALENVWRAPPER_SCRIPT="$(which virtualenvwrapper_lazy.sh)"
  source "$(which virtualenvwrapper_lazy.sh)"
fi
