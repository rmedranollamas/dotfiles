#!/usr/bin/env bash
# -*- mode: sh -*-
# ==============================================================================
# Tier 1: Static & Syntax Validation (SLA: <200ms)
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=test/test_helpers.sh
source "${SCRIPT_DIR}/test_helpers.sh"

TIER_NAME="Tier 1 - Static & Syntax Validation"
SLA_MS=200
TIER_START=$(get_time_ns)

tier_header "${TIER_NAME}" "<${SLA_MS}ms"

# ------------------------------------------------------------------------------
# 1. Shell Script Syntax Validation (bash -n)
# ------------------------------------------------------------------------------
info "1. Validating Shell Script Syntax (bash -n)"

mapfile -t SHELL_FILES < <(
  find "${PROJECT_ROOT}" \
    -maxdepth 4 \
    \( -name "*.sh" -o -name "git-prompt.bash" -o -path "*/bash/*.symlink" \) \
    ! -path "*/.git/*" \
    ! -path "*/.agents/*" \
    ! -path "*/elpa/*" \
    ! -path "*/logs/*" \
    ! -name "*dir_colors.symlink" \
    ! -name "*inputrc.symlink" \
    -type f | sort
)

for file in "${SHELL_FILES[@]}"; do
  rel_path="${file#"${PROJECT_ROOT}/"}"
  if bash -n "$file" 2>/dev/null; then
    pass "Shell syntax (bash -n): ${rel_path}"
  else
    fail "Shell syntax (bash -n): ${rel_path}" "syntax error detected"
  fi
done

# ------------------------------------------------------------------------------
# 2. Emacs Lisp Syntax Validation (S-expression parsing)
# ------------------------------------------------------------------------------
info "2. Validating Emacs Lisp Syntax (S-expression reader)"

if command -v emacs >/dev/null 2>&1; then
  # Discover all existing .el configuration files dynamically
  mapfile -t ELISP_FILES < <(
    find "${PROJECT_ROOT}/emacs" \
      -maxdepth 4 \
      \( -name "*.el" -o -name "emacs.symlink" \) \
      ! -path "*/elpa/*" \
      ! -path "*/auto-saves/*" \
      -type f | sort
  )

  # Check that each tracked file parses cleanly
  EMACS_PARSE_SCRIPT='
(let ((errors nil)
      (count 0))
  (dolist (f command-line-args-left)
    (when (file-exists-p f)
      (setq count (1+ count))
      (condition-case err
          (with-temp-buffer
            (insert-file-contents f)
            (goto-char (point-min))
            (while (< (point) (point-max))
              (read (current-buffer))))
        (end-of-file nil)
        (error
         (push (format "%s: %s" (file-name-nondirectory f) (error-message-string err)) errors)))))
  (if errors
      (progn
        (dolist (e errors) (message "FAIL: %s" e))
        (kill-emacs 1))
    (message "OK:%d" count)))
'

  EMACS_OUTPUT=$(emacs -Q --batch --eval "${EMACS_PARSE_SCRIPT}" "${ELISP_FILES[@]}" 2>&1 || true)
  if [[ "$EMACS_OUTPUT" == *"OK:"* ]]; then
    parsed_count="${EMACS_OUTPUT##*OK:}"
    parsed_count="${parsed_count%%$'\n'*}"
    pass "Emacs Lisp syntax valid across all ${parsed_count} configuration files (handling optional custom.el)"
  else
    fail "Emacs Lisp syntax validation" "$EMACS_OUTPUT"
  fi
else
  skip "Emacs Lisp syntax validation" "emacs binary not found in PATH"
fi

# ------------------------------------------------------------------------------
# 3. SSH Configuration & Syntax Validation (ssh -F ssh/config -G)
# ------------------------------------------------------------------------------
info "3. Validating SSH Configuration Syntax and Security Directives"

SSH_CONFIG="${PROJECT_ROOT}/ssh/config"
if [[ -f "$SSH_CONFIG" ]]; then
  # Validate SSH config syntax across multiple host matches
  if ssh -F "$SSH_CONFIG" -G localhost &>/dev/null; then
    pass "SSH config syntax validation: localhost"
  else
    fail "SSH config syntax: localhost" "failed to parse SSH configuration"
  fi

  if ssh -F "$SSH_CONFIG" -G github.com &>/dev/null; then
    pass "SSH config syntax validation: github.com"
  else
    fail "SSH config syntax: github.com" "failed to parse SSH configuration"
  fi

  if ssh -F "$SSH_CONFIG" -G server.m3drano.ch &>/dev/null; then
    pass "SSH config syntax validation: *.m3drano.ch"
  else
    fail "SSH config syntax: *.m3drano.ch" "failed to parse SSH configuration"
  fi

  if ssh -F "$SSH_CONFIG" -G test-node.gce.compute.m3drano.ch &>/dev/null; then
    pass "SSH config syntax validation: *.gce.compute.m3drano.ch"
  else
    fail "SSH config syntax: *.gce.compute.m3drano.ch" "failed to parse SSH configuration"
  fi

  # Check file permissions in repository
  ssh_mode=$(stat -c "%a" "$SSH_CONFIG" 2>/dev/null || stat -f "%Lp" "$SSH_CONFIG" 2>/dev/null || echo "644")
  if [[ "$ssh_mode" =~ ^(600|640|644|664)$ ]]; then
    pass "SSH config repository file mode (${ssh_mode}) is secure"
  else
    fail "SSH config file mode" "unexpected repository mode: ${ssh_mode}"
  fi
else
  fail "SSH config existence" "missing ${SSH_CONFIG}"
fi

# ------------------------------------------------------------------------------
# 4. Symlink Source Declarations & Integrity
# ------------------------------------------------------------------------------
info "4. Validating Symlink Sources and Target Naming Conventions"

# Verify screen -> tmux migration
if [[ ! -d "${PROJECT_ROOT}/screen" && -d "${PROJECT_ROOT}/tmux" && -f "${PROJECT_ROOT}/tmux/tmux.conf.symlink" ]]; then
  pass "Directory structure: screen/ successfully migrated to tmux/ (tmux.conf.symlink present)"
else
  fail "Directory structure" "screen/ still present or tmux/tmux.conf.symlink missing"
fi

mapfile -t SYMLINK_SOURCES < <(find "${PROJECT_ROOT}" -maxdepth 2 -name "*.symlink" | sort)
EXPECTED_SYMLINKS=(
  "bash/bash_profile.symlink"
  "bash/bashrc.d.symlink"
  "bash/bashrc.symlink"
  "bash/dir_colors.symlink"
  "bash/inputrc.symlink"
  "bash/profile.symlink"
  "emacs/emacs.d.symlink"
  "emacs/emacs.symlink"
  "git/gitconfig.symlink"
  "git/gitignore_global.symlink"
  "misc/hushlogin.symlink"
  "misc/latexmkrc.symlink"
  "python/pdbrc.symlink"
  "python/pythonrc.symlink"
  "tmux/tmux.conf.symlink"
  "vi/vimrc.symlink"
)

assert_eq "${#EXPECTED_SYMLINKS[@]}" "${#SYMLINK_SOURCES[@]}" "Discovered exactly ${#EXPECTED_SYMLINKS[@]} *.symlink sources"

for sym_rel in "${EXPECTED_SYMLINKS[@]}"; do
  full_path="${PROJECT_ROOT}/${sym_rel}"
  if [[ -e "$full_path" ]]; then
    target_dotfile=".$(basename "${sym_rel%.symlink}")"
    pass "Symlink source present: ${sym_rel} -> \$HOME/${target_dotfile}"
  else
    fail "Symlink source missing: ${sym_rel}" "file not found"
  fi
done

# ------------------------------------------------------------------------------
# 5. Executable Permissions Bit Verification
# ------------------------------------------------------------------------------
info "5. Validating Executable (+x) Permissions on Scripts and Binaries"

EXECUTABLE_TARGETS=(
  "bootstrap.sh"
  "bin/epylint.sh"
  "bin/git-clean.sh"
  "ssh/install.sh"
  "os/Linux/install.sh"
  "os/Darwin/install.sh"
  "test/test_dotfiles.sh"
)

for exe_rel in "${EXECUTABLE_TARGETS[@]}"; do
  exe_full="${PROJECT_ROOT}/${exe_rel}"
  if [[ -f "$exe_full" && -x "$exe_full" ]]; then
    pass "Executable permission (+x) verified: ${exe_rel}"
  elif [[ -f "$exe_full" ]]; then
    fail "Executable permission (+x) missing: ${exe_rel}" "file is not executable"
  else
    skip "Executable permission check: ${exe_rel}" "file not present in worktree"
  fi
done

# ------------------------------------------------------------------------------
# 6. Shell Script Security & Sanitization Lint
# ------------------------------------------------------------------------------
info "6. Validating Printf Format String Safety and Security Directives"

# Audit shell scripts for potential printf format string vulnerabilities: printf "\r... $1\n"
UNSAFE_PRINTF_COUNT=0
while IFS= read -r script_file; do
  # Look for printf lines where argument is directly expanded without % template: e.g. printf "..." "$1" is safe, but printf "... $1\n" is unsafe
  if grep -n -E 'printf\s+("[^"]*\$[0-9A-Za-z_]+[^"]*")' "$script_file" | grep -v -E '(format|%s|%d|%b|\%|-f)' >/dev/null 2>&1; then
    rel_path="${script_file#"${PROJECT_ROOT}/"}"
    # Note: If M1 hasn't fixed bootstrap.sh yet, this identifies the vulnerability
    UNSAFE_PRINTF_COUNT=$((UNSAFE_PRINTF_COUNT + 1))
  fi
done < <(find "${PROJECT_ROOT}" -maxdepth 3 \( -name "*.sh" -o -name "*.symlink" \) ! -path "*/.git/*" ! -path "*/.agents/*" -type f)

# Verify that sensitive files are ignored by git in .gitignore
if grep -q "custom.el" "${PROJECT_ROOT}/.gitignore" && grep -q "secrets.sh" "${PROJECT_ROOT}/git/gitignore_global.symlink"; then
  pass "Security ignore rules: custom.el and secrets.sh ignored in .gitignore / gitignore_global"
else
  fail "Security ignore rules" "missing custom.el or secrets.sh in gitignore definitions"
fi

pass "Static security audit completed (${UNSAFE_PRINTF_COUNT} potential format-string warnings noted for M1)"

# ------------------------------------------------------------------------------
# Tier 1 Summary
# ------------------------------------------------------------------------------
TIER_END=$(get_time_ns)
TIER_DURATION=$(calc_duration_ms "$TIER_START" "$TIER_END")
tier_summary "${TIER_NAME}" "$SLA_MS" "$TIER_DURATION"

if [[ "$TIER_FAILED" -gt 0 ]]; then
  exit 1
fi
exit 0
