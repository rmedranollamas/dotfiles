#!/bin/bash
# -*- mode:sh -*-
# Python REPL configuration.

# pip should only run if there is a virtualenv currently activated.
export PIP_REQUIRE_VIRTUALENV='true'

# Cache all packages globally.
export PIP_DOWNLOAD_CACHE="${HOME}/.pip/cache"

# Configuration for the Python interpreter.
export PYTHONSTARTUP="${HOME}/.pythonrc"
