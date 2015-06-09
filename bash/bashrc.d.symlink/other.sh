#!/bin/bash
# -*- mode: sh -*-
# Miscelaneus.

# Easier cd for the Home folders.
CDPATH=':~'

# Export the GPG_TTY variable.
GPG_TTY="$(tty)"
export GPG_TTY
