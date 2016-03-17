#!/bin/bash
# -*- mode: sh -*-
# Specifics for OS X.

if [[ "$(uname -s)" == "Darwin" ]] ; then
  export DISPLAY=':0.0'

  if [[ -d "${HOME}/Library/Android/sdk" ]] ; then
    export ANDROID_HOME="${HOME}/Library/Android/sdk"
    export PATH="${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${PATH}"
  fi

  if [[ -d '/Applications/Emacs.app/Contents/MacOS/bin' ]] ; then
    export PATH="/Applications/Emacs.app/Contents/MacOS/bin:${PATH}"
    export PATH="/Applications/Emacs.app/Contents/MacOS:${PATH}"
  fi
fi
