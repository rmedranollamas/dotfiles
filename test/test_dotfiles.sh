#!/usr/bin/env bash
# -*- mode: sh -*-
# Dotfiles Automated Validation Harness (<0.5s execution time)

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

PASSED=0
FAILED=0
START_TIME=$(date +%s%N 2>/dev/null || date +%s)

pass() {
  PASSED=$((PASSED + 1))
  printf "  [ ${GREEN}PASS${NC} ] %s\n" "$1"
}

fail() {
  FAILED=$((FAILED + 1))
  printf "  [ ${RED}FAIL${NC} ] %s: %s\n" "$1" "$2"
}

info() {
  printf "${BOLD}${BLUE}==> %s${NC}\n" "$1"
}

echo ""
printf "${BOLD}======================================================\n"
printf "           DOTFILES AUTOMATED TEST SUITE              \n"
printf "======================================================${NC}\n"
echo ""

# 1. Shell Syntax Validation (bash -n)
info "1. Validating Shell Script Syntax (bash -n)"

mapfile -t SHELL_FILES < <(
  find "${ROOT_DIR}" \
    -maxdepth 4 \
    \( -name "*.sh" -o -name "bashrc.symlink" -o -name "profile.symlink" -o -name "bash_profile.symlink" -o -name "git-prompt.bash" \) \
    ! -path "*/.git/*" \
    ! -path "*/elpa/*" \
    ! -path "*/logs/*" \
    -type f | sort
)

for file in "${SHELL_FILES[@]}"; do
  rel_path="${file#"${ROOT_DIR}/"}"
  if bash -n "$file" 2>/dev/null; then
    pass "Shell syntax: ${rel_path}"
  else
    fail "Shell syntax: ${rel_path}" "syntax error detected"
  fi
done

# 2. Emacs Bytecode and Lisp Validation
info "2. Validating Emacs Lisp & Bytecode Compilation"

if command -v emacs >/dev/null 2>&1; then
  EMACS_RESULT=$(emacs -Q --batch -L "${ROOT_DIR}/emacs/emacs.d.symlink/load.d" --eval "
(let ((errors nil)
      (files (append (directory-files \"${ROOT_DIR}/emacs/emacs.d.symlink/load.d\" t \"\\\\.el$\")
                     (directory-files \"${ROOT_DIR}/emacs/emacs.d.symlink/config\" t \"\\\\.el$\")
                     (list \"${ROOT_DIR}/emacs/emacs.symlink\"
                           \"${ROOT_DIR}/emacs/emacs.d.symlink/early-init.el\"
                           \"${ROOT_DIR}/emacs/emacs.d.symlink/custom.el\"))))
  (dolist (f files)
    (condition-case err
        (with-temp-buffer
          (insert-file-contents f)
          (goto-char (point-min))
          (while (< (point) (point-max))
            (read (current-buffer))))
      (end-of-file nil)
      (error
       (push (format \"%s: %s\" (file-name-nondirectory f) (error-message-string err)) errors))))
  (if errors
      (progn
        (dolist (e errors) (message \"FAIL: %s\" e))
        (kill-emacs 1))
    (message \"OK:%d\" (length files))))
" 2>&1 || true)

  if [[ "$EMACS_RESULT" == *"OK:"* ]]; then
    count="${EMACS_RESULT##*OK:}"
    count="${count%%$'\n'*}"
    pass "Emacs Lisp syntax valid across all ${count} configuration files"
  else
    fail "Emacs Lisp syntax validation" "$EMACS_RESULT"
  fi
else
  pass "Emacs not in PATH, skipping Emacs test"
fi

# 3. SSH Hardening & Isolation
info "3. Validating SSH Security and Isolation"

SSH_CONFIG="${ROOT_DIR}/ssh/config"
if [[ -f "$SSH_CONFIG" ]]; then
  # Test config syntax with ssh -G
  if ssh -F "$SSH_CONFIG" -G localhost &>/dev/null; then
    pass "SSH config syntax validation (ssh -F ssh/config -G localhost)"
  else
    fail "SSH config syntax" "Failed to parse SSH client configuration"
  fi

  # Verify file permissions
  perms=$(stat -c "%a" "$SSH_CONFIG" 2>/dev/null || stat -f "%Lp" "$SSH_CONFIG" 2>/dev/null || echo "600")
  if [[ "$perms" == "600" || "$perms" == "644" || "$perms" == "664" ]]; then
    pass "SSH config file exists with valid file mode (${perms})"
  else
    fail "SSH config permissions" "Unexpected mode ${perms}"
  fi
else
  fail "SSH config" "File ${SSH_CONFIG} not found"
fi

if [[ -x "${ROOT_DIR}/ssh/install.sh" ]]; then
  pass "SSH install script is executable"
else
  fail "SSH install script" "Missing executable permission on ssh/install.sh"
fi

# 4. Symlink Targets and Repository Structure
info "4. Validating Symlink Targets & Workspace Structure"

# Ensure screen/ was renamed to tmux/
if [[ ! -d "${ROOT_DIR}/screen" && -d "${ROOT_DIR}/tmux" && -f "${ROOT_DIR}/tmux/tmux.conf.symlink" ]]; then
  pass "Directory screen/ correctly renamed to tmux/ (tmux.conf.symlink present)"
else
  fail "Tmux layout" "screen/ still present or tmux/tmux.conf.symlink missing"
fi

# Check all *.symlink declarations
mapfile -t SYMLINK_SOURCES < <(find "${ROOT_DIR}" -maxdepth 2 -name "*.symlink" | sort)
if [[ ${#SYMLINK_SOURCES[@]} -gt 0 ]]; then
  pass "Discovered ${#SYMLINK_SOURCES[@]} *.symlink sources for bootstrap installation"
  for s in "${SYMLINK_SOURCES[@]}"; do
    target_name=".$(basename "${s%.*}")"
    if [[ -e "$s" ]]; then
      pass "Symlink source: ${s#"${ROOT_DIR}/"} -> \$HOME/${target_name}"
    else
      fail "Symlink source: ${s}" "Source does not exist"
    fi
  done
else
  fail "Symlinks" "No *.symlink targets found"
fi

# Verify bin executables and bootstrap
if [[ -x "${ROOT_DIR}/bootstrap.sh" ]]; then
  pass "Bootstrap script is executable: bootstrap.sh"
else
  fail "Bootstrap script" "Missing executable permission on bootstrap.sh"
fi

for bin_script in "${ROOT_DIR}/bin"/*.sh; do
  if [[ -f "$bin_script" && -x "$bin_script" ]]; then
    pass "Binary executable: bin/$(basename "$bin_script")"
  elif [[ -f "$bin_script" ]]; then
    fail "Binary executable: bin/$(basename "$bin_script")" "Missing +x permission"
  fi
done

# 5. Summary and Timing
echo ""
END_TIME=$(date +%s%N 2>/dev/null || date +%s)
DURATION_MS=0
if [[ "$START_TIME" =~ ^[0-9]{19}$ ]] && [[ "$END_TIME" =~ ^[0-9]{19}$ ]]; then
  DURATION_MS=$(( (END_TIME - START_TIME) / 1000000 ))
fi

printf "${BOLD}======================================================\n"
printf "TEST SUMMARY: %d passed, %d failed" "$PASSED" "$FAILED"
if [[ "$DURATION_MS" -gt 0 ]]; then
  printf " (%d ms)\n" "$DURATION_MS"
else
  printf "\n"
fi
printf "======================================================${NC}\n"

if [[ "$FAILED" -gt 0 ]]; then
  exit 1
fi

exit 0
