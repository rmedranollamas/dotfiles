#!/bin/bash
# -*- mode: sh -*-
# Options governing the shell command history, mostly for bash.

# Append to the history file, multi-line command handling, and verify history expansion.
shopt -s cmdhist histappend lithist histverify

# History format, size, and control options.
HISTCONTROL='ignoreboth:erasedups'
HISTTIMEFORMAT='%F %T  '
HISTSIZE=100000
HISTFILESIZE=200000
HISTIGNORE='&:[bf]g:exit:quit:q:clear:cls:history:pwd:ls:l:ll:la'

# Integration with fzf key-bindings across multiple distros and package managers.
fzf_bindings=(
  "/usr/share/doc/fzf/examples/key-bindings.bash"
  "/usr/share/fzf/shell/key-bindings.bash"
  "/usr/share/fzf/key-bindings.bash"
  "/opt/homebrew/opt/fzf/shell/key-bindings.bash"
  "/usr/local/opt/fzf/shell/key-bindings.bash"
  "${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.bash}"
  "/home/linuxbrew/.linuxbrew/opt/fzf/shell/key-bindings.bash"
  "${HOME}/.linuxbrew/opt/fzf/shell/key-bindings.bash"
  "${HOME}/.fzf.bash"
  "${HOME}/.fzf/shell/key-bindings.bash"
)

for fzf_binding in "${fzf_bindings[@]}"; do
  if [[ -n "$fzf_binding" && -r "$fzf_binding" ]]; then
    source "$fzf_binding"
    break
  fi
done
unset fzf_bindings fzf_binding
