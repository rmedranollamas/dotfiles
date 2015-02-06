#!/bin/bash
# -*- mode: sh -*-
# Miscelaneus.

# Easier cd for the Home folders.
CDPATH=':~'

# Look for the Cloud SDK config file.
if [[ -f "${HOME}/.bashrc_gcloud" ]] ; then
  source "${HOME}/.bashrc_gcloud"
fi
