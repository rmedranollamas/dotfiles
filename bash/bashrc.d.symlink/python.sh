#!/bin/bash
# -*- mode:sh -*-
# Python REPL configuration.

export PYTHONSTARTUP="${HOME}/.pythonrc"

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
