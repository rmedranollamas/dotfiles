#!/bin/bash
# -*- mode:sh -*-
# Python REPL configuration.

# cache pip-installed packages to avoid re-downloading
export PIP_DOWNLOAD_CACHE="${HOME}/.pip/cache"

# pip should only run if there is a virtualenv currently activated
export PIP_REQUIRE_VIRTUALENV='true'

# Configuration for the Python interpreter.
export PYTHONSTARTUP="$HOME/.pythonrc"
