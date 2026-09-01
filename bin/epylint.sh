#!/bin/bash
# Multi-tier Python linter cascade for Emacs/Flymake/CLI:
# ruff check -> epylint -> pylint -> clean exit 0

target="${1:-}"

if [[ -z "${target}" ]]; then
  echo "Usage: $(basename "$0") <python-file>" >&2
  exit 0
fi

if command -v ruff >/dev/null 2>&1 ; then
  ruff check "$@" 2>&1 || true
elif command -v epylint >/dev/null 2>&1 ; then
  epylint "$@" 2>&1 || true
elif command -v pylint >/dev/null 2>&1 ; then
  pylint --single-file=y --output-format=parseable "$target" 2>/dev/null | sed -e "s/\[\([WC]\)/warning \[\1/" || true
else
  echo "[epylint.sh] No supported Python linter found (ruff, epylint, pylint)." >&2
fi

exit 0
