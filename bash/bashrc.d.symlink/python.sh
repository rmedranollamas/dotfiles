#!/bin/bash
# -*- mode:sh -*-
# Python REPL configuration.

# pip should only run if there is a virtualenv currently activated.
export PIP_REQUIRE_VIRTUALENV='true'

# Cache all packages globally.
export PIP_DOWNLOAD_CACHE="${HOME}/.pip/cache"

# Configuration for the Python interpreter.
export PYTHONSTARTUP="${HOME}/.pythonrc"

# virtualenvwrapper config.
export WORKON_HOME="${HOME}/.virtualenvs"
export PROJECT_HOME="${HOME}/Code"
export VIRTUALENV_PYTHON="$(which python3)"
export VIRTUALENVWRAPPER_PYTHON="${VIRTUALENV_PYTHON}"
export VIRTUALENVWRAPPER_SCRIPT='/usr/local/bin/virtualenvwrapper.sh'
source '/usr/local/bin/virtualenvwrapper_lazy.sh'
