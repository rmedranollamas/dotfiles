#!/bin/bash

log="${DOTFILES_ROOT}/logs/python.install.log"

# On Linux, we prefer always standard packages.
if [[ "$(uname -s)" == "Darwin" ]] ; then
  # Install some system-wide Python tools.
  PIP_REQUIRE_VIRTUALENV='' pip install --upgrade pip virtualenv > "${log}" 2>&1
fi

unset log
