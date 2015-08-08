#!/bin/bash
# -*- mode: sh -*-
# Sets up the Google Cloud SDK.

# Always use the default Python with glcoud.
export CLOUDSDK_PYTHON="$(which python)"

# TODO(m3drano): Make this path dynamic.
if [[ -f "${HOME}/Code/google-cloud-sdk/path.bash.inc" ]] ; then
  source "${HOME}/Code/google-cloud-sdk/path.bash.inc"
fi

# TODO(m3drano): Make this path dynamic.
if [[ -f "${HOME}/Code/google-cloud-sdk/completion.bash.inc" ]] ; then
  source "${HOME}/Code/google-cloud-sdk/completion.bash.inc"
fi
