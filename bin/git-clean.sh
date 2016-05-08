#!/bin/sh

DEPTH=1000000

git fetch --depth="${DEPTH}"

git fsck --full --unreachable
git repack -a -d -l --depth="${DEPTH}"
git prune --verbose
git gc --aggressive --prune=now

unset DEPTH
