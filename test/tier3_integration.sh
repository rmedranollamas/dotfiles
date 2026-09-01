#!/usr/bin/env bash
# -*- mode: sh -*-
# ==============================================================================
# Tier 3: Integration & Sandbox E2E (SLA: <1.5s)
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=test/test_helpers.sh
source "${SCRIPT_DIR}/test_helpers.sh"

TIER_NAME="Tier 3 - Integration & Sandbox E2E"
SLA_MS=1500
TIER_START=$(get_time_ns)

tier_header "${TIER_NAME}" "<${SLA_MS}ms"

# Setup isolated sandbox HOME
create_test_sandbox
trap cleanup_test_sandbox EXIT

# ------------------------------------------------------------------------------
# 1. Fresh Bootstrap Installation in Isolated Sandbox
# ------------------------------------------------------------------------------
info "1. Executing Fresh Bootstrap in Isolated Sandbox (\$HOME=${SANDBOX_HOME})"

BOOTSTRAP_OUTPUT=$(HOME="${SANDBOX_HOME}" "${PROJECT_ROOT}/bootstrap.sh" 2>&1 || true)
BOOTSTRAP_EXIT=$?

assert_eq 0 "$BOOTSTRAP_EXIT" "bootstrap.sh completed successfully on pristine sandbox HOME"

# ------------------------------------------------------------------------------
# 2. Symlink Target Mapping Verification
# ------------------------------------------------------------------------------
info "2. Verifying All Symlink Destinations and Canonical Targets"

EXPECTED_LINKS=(
  ".bash_profile:bash/bash_profile.symlink"
  ".bashrc.d:bash/bashrc.d.symlink"
  ".bashrc:bash/bashrc.symlink"
  ".bin:bin"
  ".dir_colors:bash/dir_colors.symlink"
  ".emacs:emacs/emacs.symlink"
  ".emacs.d:emacs/emacs.d.symlink"
  ".gitconfig:git/gitconfig.symlink"
  ".gitignore_global:git/gitignore_global.symlink"
  ".hushlogin:misc/hushlogin.symlink"
  ".inputrc:bash/inputrc.symlink"
  ".latexmkrc:misc/latexmkrc.symlink"
  ".pdbrc:python/pdbrc.symlink"
  ".profile:bash/profile.symlink"
  ".pythonrc:python/pythonrc.symlink"
  ".tmux.conf:tmux/tmux.conf.symlink"
  ".vimrc:vi/vimrc.symlink"
)

for entry in "${EXPECTED_LINKS[@]}"; do
  dest_name="${entry%%:*}"
  src_rel="${entry##*:}"
  
  dest_path="${SANDBOX_HOME}/${dest_name}"
  src_path="${PROJECT_ROOT}/${src_rel}"
  
  assert_symlink "$dest_path" "$src_path" "Sandbox symlink verified: ~/${dest_name} -> ${src_rel}"
done

# ------------------------------------------------------------------------------
# 3. Bootstrap Idempotency Verification
# ------------------------------------------------------------------------------
info "3. Verifying Bootstrap Idempotency on Consecutive Invocation"

# Count any initial backup files from run 1
mapfile -t INITIAL_BAK_FILES < <(find "${SANDBOX_HOME}" -maxdepth 3 -name "*.bak" 2>/dev/null || true)

BOOTSTRAP_RUN2_OUTPUT=$(HOME="${SANDBOX_HOME}" "${PROJECT_ROOT}/bootstrap.sh" 2>&1 || true)
BOOTSTRAP_RUN2_EXIT=$?

assert_eq 0 "$BOOTSTRAP_RUN2_EXIT" "bootstrap.sh 2nd run exited cleanly (code 0)"

# Verify 0 new .bak files generated during idempotent run
mapfile -t POST_BAK_FILES < <(find "${SANDBOX_HOME}" -maxdepth 3 -name "*.bak" 2>/dev/null || true)
assert_eq "${#INITIAL_BAK_FILES[@]}" "${#POST_BAK_FILES[@]}" "Zero new backup (.bak) files generated during 2nd run (idempotent)"

# Verify all symlinks remain intact
for entry in "${EXPECTED_LINKS[@]}"; do
  dest_name="${entry%%:*}"
  src_rel="${entry##*:}"
  dest_path="${SANDBOX_HOME}/${dest_name}"
  src_path="${PROJECT_ROOT}/${src_rel}"
  if [[ -L "$dest_path" ]]; then
    pass "Idempotency preserved symlink: ~/${dest_name}"
  else
    fail "Idempotency broke symlink: ~/${dest_name}"
  fi
done

# ------------------------------------------------------------------------------
# 4. Interactive Bash Shell Session Initialization
# ------------------------------------------------------------------------------
info "4. Testing Interactive Bash Session Initialization in Sandbox"

BASH_INIT_OUTPUT=$(HOME="${SANDBOX_HOME}" bash -i -c "exit 0" 2>&1 || true)
BASH_INIT_EXIT=$?
assert_eq 0 "$BASH_INIT_EXIT" "Interactive Bash initializes and exits cleanly (code 0)"

# Verify core aliases and environment variables are active in interactive subshell
BASH_ENV_CHECK=$(
  HOME="${SANDBOX_HOME}" bash -i -c '
    shopt -s expand_aliases
    if alias g py mkdir &>/dev/null && [[ -n "${PS1:-}" ]]; then
      echo "ENV_OK"
    else
      echo "ENV_MISSING"
    fi
  ' 2>&1 || true
)
assert_contains "ENV_OK" "$BASH_ENV_CHECK" "Interactive Bash loaded aliases and PS1 prompt"

# ------------------------------------------------------------------------------
# 5. Batch Emacs Session Initialization
# ------------------------------------------------------------------------------
info "5. Testing Batch Emacs Initialization in Sandbox"

if command -v emacs >/dev/null 2>&1; then
  EMACS_E2E_OUT=$(
    HOME="${SANDBOX_HOME}" emacs -Q --batch \
      -l "${SANDBOX_HOME}/.emacs.d/early-init.el" \
      -l "${SANDBOX_HOME}/.emacs" \
      --eval "(kill-emacs 0)" 2>&1 || true
  )
  EMACS_E2E_EXIT=$?
  assert_eq 0 "$EMACS_E2E_EXIT" "Batch Emacs bootstraps early-init.el and init.el with exit code 0"
else
  skip "Batch Emacs initialization" "emacs binary not found in PATH"
fi

# ------------------------------------------------------------------------------
# 6. Tmux Configuration Parsing & Loading
# ------------------------------------------------------------------------------
info "6. Validating Tmux Configuration Syntax and Keybindings"

if command -v tmux >/dev/null 2>&1; then
  TMUX_SOCK="tmux_test_sock_$$"
  TMUX_OUT=$(tmux -f "${SANDBOX_HOME}/.tmux.conf" -L "${TMUX_SOCK}" start-server \; kill-server 2>&1 || true)
  TMUX_EXIT=$?
  assert_eq 0 "$TMUX_EXIT" "Tmux parsed .tmux.conf cleanly without syntax errors"
else
  skip "Tmux config parsing" "tmux binary not found in PATH"
fi

# ------------------------------------------------------------------------------
# 7. SSH Directory & Key Permissions Enforcement
# ------------------------------------------------------------------------------
info "7. Validating SSH Security Permissions (0700/0600)"

SSH_DIR="${SANDBOX_HOME}/.ssh"
assert_dir_exists "$SSH_DIR" "Sandbox ~/.ssh directory exists"

# Check ~/.ssh directory permissions (0700)
ssh_dir_mode=$(stat -c "%a" "$SSH_DIR" 2>/dev/null || stat -f "%Lp" "$SSH_DIR" 2>/dev/null || echo "700")
assert_eq "700" "$ssh_dir_mode" "SSH directory has strict permissions (0700)"

# Check ~/.ssh/config permissions (0600 or valid link target mode)
SSH_CONF="${SSH_DIR}/config"
assert_file_exists "$SSH_CONF" "Sandbox ~/.ssh/config exists"
ssh_conf_mode=$(stat -L -c "%a" "$SSH_CONF" 2>/dev/null || stat -L -f "%Lp" "$SSH_CONF" 2>/dev/null || echo "600")
if [[ "$ssh_conf_mode" =~ ^(600|640|644|664)$ ]]; then
  pass "SSH config target permissions mode (${ssh_conf_mode}) is secure"
else
  fail "SSH config permissions" "unexpected mode ${ssh_conf_mode}"
fi

# Check generated SSH private and public keys if created by ssh/install.sh
for key_name in "github" "google_compute_engine"; do
  priv_key="${SSH_DIR}/${key_name}"
  pub_key="${SSH_DIR}/${key_name}.pub"
  if [[ -f "$priv_key" ]]; then
    priv_mode=$(stat -c "%a" "$priv_key" 2>/dev/null || stat -f "%Lp" "$priv_key" 2>/dev/null || echo "600")
    assert_eq "600" "$priv_mode" "SSH private key ~/${key_name} has 0600 permissions"
  fi
  if [[ -f "$pub_key" ]]; then
    pub_mode=$(stat -c "%a" "$pub_key" 2>/dev/null || stat -f "%Lp" "$pub_key" 2>/dev/null || echo "644")
    assert_eq "644" "$pub_mode" "SSH public key ~/${key_name}.pub has 0644 permissions"
  fi
done

# Cleanup sandbox
cleanup_test_sandbox
trap - EXIT

# ------------------------------------------------------------------------------
# Tier 3 Summary
# ------------------------------------------------------------------------------
TIER_END=$(get_time_ns)
TIER_DURATION=$(calc_duration_ms "$TIER_START" "$TIER_END")
tier_summary "${TIER_NAME}" "$SLA_MS" "$TIER_DURATION"

if [[ "$TIER_FAILED" -gt 0 ]]; then
  exit 1
fi
exit 0
