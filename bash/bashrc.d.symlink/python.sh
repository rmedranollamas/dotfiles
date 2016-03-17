#!/bin/bash
# -*- mode:sh -*-
# Python REPL configuration.

# Configuration for the Python interpreter.
export PYTHONSTARTUP="${HOME}/.pythonrc"

# virtualenvwrapper and virtualenv.
export VIRTUALENV_PYTHON="$(which python)"
export VIRTUALENVWRAPPER_PYTHON="${VIRTUALENV_PYTHON}"
export WORKON_HOME="${HOME}/Code/.virtualenvs"

# virtualenvwrapper config for MacPorts.
if [[ -f '/opt/local/bin/virtualenvwrapper_lazy.sh-3.4' ]] ; then
  export VIRTUALENVWRAPPER_SCRIPT='/opt/local/bin/virtualenvwrapper.sh-3.4'
  source '/opt/local/bin/virtualenvwrapper_lazy.sh-3.4'
fi
