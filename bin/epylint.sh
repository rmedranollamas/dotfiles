#!/bin/bash

if [[ -x "`which epylint`" ]] ; then
  exec epylint "$1"
else
  pylint --single-file=y --output-format=parseable "$1" | sed -e "s/\[\([WC]\)/warning \[\1/"
fi

# Make sure return value is "good"
true
