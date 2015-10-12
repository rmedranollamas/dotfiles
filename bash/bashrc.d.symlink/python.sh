#!/bin/bash
# -*- mode:sh -*-
# Python REPL configuration.

# pip should only run if there is a virtualenv currently activated.
export PIP_REQUIRE_VIRTUALENV='true'

# Configuration for the Python interpreter.
export PYTHONSTARTUP="${HOME}/.pythonrc"

# virtualenvwrapper config.
if [[ -f '/opt/local/bin/virtualenvwrapper_lazy.sh-3.4' ]] ; then
  export WORKON_HOME="${HOME}/.virtualenvs"
  export PROJECT_HOME="${HOME}/Code"
  export VIRTUALENV_PYTHON="$(which python3)"
  export VIRTUALENVWRAPPER_PYTHON="${VIRTUALENV_PYTHON}"
  export VIRTUALENVWRAPPER_SCRIPT='/opt/local/bin/virtualenvwrapper.sh-3.4'
  source '/opt/local/bin/virtualenvwrapper_lazy.sh-3.4'
fi
