#!/bin/bash
# -*- mode:sh -*-
# Python REPL configuration.

# pip should only run if there is a virtualenv currently activated
export PIP_REQUIRE_VIRTUALENV='true'

# Configuration for the Python interpreter.
export PYTHONSTARTUP="$HOME/.pythonrc"
