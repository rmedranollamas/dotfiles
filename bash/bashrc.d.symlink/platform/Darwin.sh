#!/bin/bash
# -*- mode: sh -*-
# Specifics for OS X.

# Android Studio platform tools.
ANDROID_HOME="${HOME}/Library/Android/sdk"
export ANDROID_HOME

PATH="${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools"
export PATH
