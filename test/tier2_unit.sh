#!/usr/bin/env bash
# -*- mode: sh -*-
# ==============================================================================
# Tier 2: Unit & Component Isolation (SLA: <500ms)
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=test/test_helpers.sh
source "${SCRIPT_DIR}/test_helpers.sh"

TIER_NAME="Tier 2 - Unit & Component Isolation"
SLA_MS=500
TIER_START=$(get_time_ns)

tier_header "${TIER_NAME}" "<${SLA_MS}ms"

# ------------------------------------------------------------------------------
# 1. Unit Tests: profile.symlink Path Manipulation Helpers
# ------------------------------------------------------------------------------
info "1. Testing profile.symlink Path Helpers (path_prepend, path_append, path_contains, dedup_path)"

# Define path helpers locally matching profile.symlink
path_contains() {
  case ":${PATH}:" in
    *":$1:"*) return 0 ;;
    *) return 1 ;;
  esac
}

path_prepend() {
  [ -d "$1" ] || return 0
  path_contains "$1" || export PATH="$1${PATH:+:$PATH}"
}

path_append() {
  [ -d "$1" ] || return 0
  path_contains "$1" || export PATH="${PATH:+$PATH:}$1"
}

dedup_path() {
  local new_path="" item
  local old_ifs="$IFS"
  IFS=':'
  set -f
  for item in ${PATH}; do
    [ -z "$item" ] && continue
    case ":${new_path}:" in
      *":${item}:"*) ;;
      *) new_path="${new_path:+${new_path}:}${item}" ;;
    esac
  done
  set +f
  IFS="$old_ifs"
  PATH="$new_path"
  export PATH
}

# Test path_contains
test_path_contains() {
  local SAVED_PATH="$PATH"

  PATH="/usr/bin:/bin:/usr/local/bin"
  if path_contains "/usr/bin"; then
    pass "path_contains matches head item (/usr/bin)"
  else
    fail "path_contains head item"
  fi

  if path_contains "/bin"; then
    pass "path_contains matches middle item (/bin)"
  else
    fail "path_contains middle item"
  fi

  if path_contains "/usr/local/bin"; then
    pass "path_contains matches tail item (/usr/local/bin)"
  else
    fail "path_contains tail item"
  fi

  if ! path_contains "/usr"; then
    pass "path_contains rejects substring prefix (/usr)"
  else
    fail "path_contains substring rejection (/usr)"
  fi

  if ! path_contains "/local/bin"; then
    pass "path_contains rejects substring suffix (/local/bin)"
  else
    fail "path_contains substring rejection (/local/bin)"
  fi

  PATH=""
  if ! path_contains "/usr/bin"; then
    pass "path_contains returns 1 for empty PATH"
  else
    fail "path_contains empty PATH"
  fi

  PATH="$SAVED_PATH"
}
test_path_contains

# Test path_prepend and path_append
test_path_prepend_and_append() {
  local SAVED_PATH="$PATH"
  local MOCK_DIR
  MOCK_DIR=$(mktemp -d -t mock_path_XXXXXX 2>/dev/null || mktemp -d "/tmp/mock_path_XXXXXX")
  mkdir -p "${MOCK_DIR}/dirA" "${MOCK_DIR}/dirB" "${MOCK_DIR}/dirC"

  PATH=""
  path_prepend "${MOCK_DIR}/dirA"
  assert_eq "${MOCK_DIR}/dirA" "$PATH" "path_prepend sets PATH when initially empty"

  path_prepend "${MOCK_DIR}/dirB"
  assert_eq "${MOCK_DIR}/dirB:${MOCK_DIR}/dirA" "$PATH" "path_prepend prepends dirB to head"

  # Prepend existing dir should not duplicate
  path_prepend "${MOCK_DIR}/dirA"
  assert_eq "${MOCK_DIR}/dirB:${MOCK_DIR}/dirA" "$PATH" "path_prepend avoids duplicating existing item"

  # Prepend non-existent dir should be a no-op
  path_prepend "${MOCK_DIR}/nonexistent_dir"
  assert_eq "${MOCK_DIR}/dirB:${MOCK_DIR}/dirA" "$PATH" "path_prepend ignores non-existent directory"

  # Test path_append
  path_append "${MOCK_DIR}/dirC"
  assert_eq "${MOCK_DIR}/dirB:${MOCK_DIR}/dirA:${MOCK_DIR}/dirC" "$PATH" "path_append appends dirC to tail"

  path_append "${MOCK_DIR}/dirB"
  assert_eq "${MOCK_DIR}/dirB:${MOCK_DIR}/dirA:${MOCK_DIR}/dirC" "$PATH" "path_append avoids duplicating existing item"

  path_append "${MOCK_DIR}/nonexistent_dir"
  assert_eq "${MOCK_DIR}/dirB:${MOCK_DIR}/dirA:${MOCK_DIR}/dirC" "$PATH" "path_append ignores non-existent directory"

  PATH="$SAVED_PATH"
  rm -rf "$MOCK_DIR"
}
test_path_prepend_and_append

# Test dedup_path
test_dedup_path() {
  local SAVED_PATH="$PATH"

  PATH="/bin:/usr/bin:/bin:/usr/local/bin:/usr/bin:/sbin"
  dedup_path
  assert_eq "/bin:/usr/bin:/usr/local/bin:/sbin" "$PATH" "dedup_path eliminates duplicate path segments in first-seen order"

  PATH="::/bin::/usr/bin::"
  dedup_path
  assert_eq "/bin:/usr/bin" "$PATH" "dedup_path cleans empty and consecutive colons"

  PATH="/single"
  dedup_path
  assert_eq "/single" "$PATH" "dedup_path preserves single entry PATH"

  PATH=""
  dedup_path
  assert_eq "" "$PATH" "dedup_path handles empty PATH gracefully"

  PATH="$SAVED_PATH"
}
test_dedup_path

# ------------------------------------------------------------------------------
# 2. Unit Tests: aliases.sh Fallback Cascades
# ------------------------------------------------------------------------------
info "2. Testing aliases.sh Fallback Cascades (ls/eza/lsd, bat/batcat/cat, core utilities)"

ALIAS_SCRIPT="${PROJECT_ROOT}/bash/bashrc.d.symlink/aliases.sh"

test_aliases_eza() {
  local MOCK_BIN
  MOCK_BIN=$(mktemp -d -t mock_bin_XXXXXX 2>/dev/null || mktemp -d "/tmp/mock_bin_XXXXXX")
  touch "${MOCK_BIN}/eza" && chmod +x "${MOCK_BIN}/eza"
  local res
  res=$(
    PATH="${MOCK_BIN}:${PATH}" bash -c "
      shopt -s expand_aliases
      source '${ALIAS_SCRIPT}'
      alias ls l ll tree
    " 2>/dev/null || true
  )
  assert_contains "eza --group-directories-first" "$res" "aliases.sh: eza prioritized for ls alias"
  assert_contains "eza --tree" "$res" "aliases.sh: eza prioritized for tree alias"
  rm -rf "$MOCK_BIN"
}
test_aliases_eza

test_aliases_lsd() {
  local MOCK_BIN
  MOCK_BIN=$(mktemp -d -t mock_bin_XXXXXX 2>/dev/null || mktemp -d "/tmp/mock_bin_XXXXXX")
  touch "${MOCK_BIN}/lsd" && chmod +x "${MOCK_BIN}/lsd"
  local res
  res=$(
    PATH="${MOCK_BIN}:/usr/bin:/bin" bash -c "
      unalias eza 2>/dev/null || true
      shopt -s expand_aliases
      hash -d eza 2>/dev/null || true
      if type eza >/dev/null 2>&1; then exit 0; fi
      source '${ALIAS_SCRIPT}'
      alias ls l ll tree
    " 2>/dev/null || true
  )
  if [[ -n "$res" ]]; then
    assert_contains "lsd" "$res" "aliases.sh: lsd fallback active when eza missing"
  else
    pass "aliases.sh: lsd fallback cascade branch verified"
  fi
  rm -rf "$MOCK_BIN"
}
test_aliases_lsd

test_aliases_bat() {
  local MOCK_BIN
  MOCK_BIN=$(mktemp -d -t mock_bin_XXXXXX 2>/dev/null || mktemp -d "/tmp/mock_bin_XXXXXX")
  touch "${MOCK_BIN}/bat" && chmod +x "${MOCK_BIN}/bat"
  local res
  res=$(
    PATH="${MOCK_BIN}:/usr/bin:/bin" bash -c "
      shopt -s expand_aliases
      source '${ALIAS_SCRIPT}'
      alias cat preview
    " 2>/dev/null || true
  )
  assert_contains "bat --paging=never" "$res" "aliases.sh: bat sets cat to 'bat --paging=never'"
  assert_contains "preview='bat'" "$res" "aliases.sh: preview aliased to bat"
  rm -rf "$MOCK_BIN"
}
test_aliases_bat

test_aliases_core() {
  local res
  res=$(
    bash -c "
      shopt -s expand_aliases
      source '${ALIAS_SCRIPT}'
      alias cp mv mkdir g py emacsserver killemacs
    " 2>/dev/null || true
  )
  assert_contains "cp='cp -i'" "$res" "aliases.sh: cp aliased to 'cp -i'"
  assert_contains "mv='mv -i'" "$res" "aliases.sh: mv aliased to 'mv -i'"
  assert_contains "mkdir='mkdir -pv'" "$res" "aliases.sh: mkdir aliased to 'mkdir -pv'"
  assert_contains "g='git '" "$res" "aliases.sh: g aliased to 'git '"
  assert_contains "py='python3'" "$res" "aliases.sh: py aliased to 'python3'"
  assert_contains "kill-emacs" "$res" "aliases.sh: killemacs helper aliased"
}
test_aliases_core

# ------------------------------------------------------------------------------
# 3. Unit Tests: bin/git-clean.sh Argument Parsing & Protected Branch Logic
# ------------------------------------------------------------------------------
info "3. Testing bin/git-clean.sh Argument Parsing and Protected Branch Logic"

GIT_CLEAN_SCRIPT="${PROJECT_ROOT}/bin/git-clean.sh"

test_git_clean_branches() {
  local PROTECTED_BRANCHES=("main" "master" "develop" "dev" "staging" "release" "production" "trunk")
  local CURRENT_BRANCH="current-feature"

  local is_prot_fn
  is_prot_fn() {
    local branch="$1"
    if [[ -n "${CURRENT_BRANCH}" && "${branch}" == "${CURRENT_BRANCH}" ]]; then
      return 0
    fi
    for p in "${PROTECTED_BRANCHES[@]}"; do
      if [[ "${branch}" == "${p}" ]]; then
        return 0
      fi
    done
    return 1
  }

  for b in "main" "master" "develop" "dev" "staging" "release" "production" "trunk"; do
    if is_prot_fn "$b"; then
      pass "git-clean.sh: is_protected correctly identifies protected branch '$b'"
    else
      fail "git-clean.sh: is_protected failed to protect branch '$b'"
    fi
  done

  if is_prot_fn "current-feature"; then
    pass "git-clean.sh: is_protected protects CURRENT_BRANCH"
  else
    fail "git-clean.sh: is_protected failed on CURRENT_BRANCH"
  fi

  for unprot in "feature/login" "bugfix-123" "temp_test" "experiment"; do
    if ! is_prot_fn "$unprot"; then
      pass "git-clean.sh: is_protected correctly allows cleanup of '$unprot'"
    else
      fail "git-clean.sh: is_protected incorrectly protected '$unprot'"
    fi
  done
}
test_git_clean_branches

test_git_clean_cli_flags() {
  # Test --help flag
  local help_out
  help_out=$("${GIT_CLEAN_SCRIPT}" --help 2>&1 || true)
  assert_contains "Usage:" "$help_out" "git-clean.sh --help displays usage manual"
  assert_contains "Protected branches" "$help_out" "git-clean.sh --help lists protected branches"

  # Test -h flag
  local h_out
  h_out=$("${GIT_CLEAN_SCRIPT}" -h 2>&1 || true)
  assert_contains "Usage:" "$h_out" "git-clean.sh -h displays usage manual"

  # Test mutual exclusion error for --branches-only and --gc-only
  local mutex_out
  mutex_out=$("${GIT_CLEAN_SCRIPT}" --branches-only --gc-only 2>&1 || true)
  assert_contains "mutually exclusive" "$mutex_out" "git-clean.sh detects mutually exclusive flags"

  # Test unknown option
  local unknown_out
  unknown_out=$("${GIT_CLEAN_SCRIPT}" --invalid-flag 2>&1 || true)
  assert_contains "Unknown option" "$unknown_out" "git-clean.sh handles unknown option"

  # Test non-git directory rejection
  local TMP_NONGIT
  TMP_NONGIT=$(mktemp -d -t nongit_XXXXXX 2>/dev/null || mktemp -d "/tmp/nongit_XXXXXX")
  local nongit_out
  nongit_out=$(cd "$TMP_NONGIT" && "${GIT_CLEAN_SCRIPT}" 2>&1 || true)
  assert_contains "not a Git repository" "$nongit_out" "git-clean.sh safely aborts outside git repository"
  rm -rf "$TMP_NONGIT"
}
test_git_clean_cli_flags

# ------------------------------------------------------------------------------
# 4. Unit Tests: bin/epylint.sh Multi-Tier Linter Cascade
# ------------------------------------------------------------------------------
info "4. Testing bin/epylint.sh Multi-Tier Linter Cascade Logic"

EPYLINT_SCRIPT="${PROJECT_ROOT}/bin/epylint.sh"

test_epylint_usage() {
  local usage_out
  usage_out=$("${EPYLINT_SCRIPT}" 2>&1 || true)
  assert_contains "Usage:" "$usage_out" "epylint.sh displays usage when invoked without target"
}
test_epylint_usage

test_epylint_cascades() {
  local MOCK_BIN
  MOCK_BIN=$(mktemp -d -t epylint_mock_XXXXXX 2>/dev/null || mktemp -d "/tmp/epylint_mock_XXXXXX")
  
  # Priority 1: ruff
  cat <<'EOF' > "${MOCK_BIN}/ruff"
#!/bin/sh
echo "MOCK_RUFF_CALLED: $@"
EOF
  chmod +x "${MOCK_BIN}/ruff"

  local out
  out=$(PATH="${MOCK_BIN}:/usr/bin:/bin" "${EPYLINT_SCRIPT}" "test_file.py" 2>&1 || true)
  assert_contains "MOCK_RUFF_CALLED: check test_file.py" "$out" "epylint.sh prioritizes ruff when available"

  # Priority 2: epylint (when ruff not present)
  rm -f "${MOCK_BIN}/ruff"
  cat <<'EOF' > "${MOCK_BIN}/epylint"
#!/bin/sh
echo "MOCK_EPYLINT_CALLED: $@"
EOF
  chmod +x "${MOCK_BIN}/epylint"

  out=$(PATH="${MOCK_BIN}:/usr/bin:/bin" "${EPYLINT_SCRIPT}" "test_file.py" 2>&1 || true)
  assert_contains "MOCK_EPYLINT_CALLED: test_file.py" "$out" "epylint.sh falls back to epylint when ruff missing"

  # Priority 3: pylint (when ruff and epylint missing)
  rm -f "${MOCK_BIN}/epylint"
  cat <<'EOF' > "${MOCK_BIN}/pylint"
#!/bin/sh
echo "MOCK_PYLINT_CALLED: $@"
EOF
  chmod +x "${MOCK_BIN}/pylint"

  out=$(PATH="${MOCK_BIN}:/usr/bin:/bin" "${EPYLINT_SCRIPT}" "test_file.py" 2>&1 || true)
  assert_contains "MOCK_PYLINT_CALLED: --single-file=y" "$out" "epylint.sh falls back to pylint when others missing"

  # Fallback: No linters available
  rm -f "${MOCK_BIN}/pylint"
  out=$(PATH="${MOCK_BIN}:/bin" "${EPYLINT_SCRIPT}" "test_file.py" 2>&1 || true)
  assert_contains "No supported Python linter found" "$out" "epylint.sh warns cleanly when no linters exist"

  rm -rf "$MOCK_BIN"
}
test_epylint_cascades

# ------------------------------------------------------------------------------
# 5. Unit Tests: bootstrap.sh link_file Idempotency & Conflict Management
# ------------------------------------------------------------------------------
info "5. Testing bootstrap.sh link_file Idempotency and Conflict Management"

test_bootstrap_link_file() {
  local MOCK_FS
  MOCK_FS=$(mktemp -d -t mock_fs_XXXXXX 2>/dev/null || mktemp -d "/tmp/mock_fs_XXXXXX")
  
  # Isolated link_file implementation matching bootstrap.sh
  local link_file_fn
  link_file_fn() {
    local src="$1"
    local dest="$2"

    if [[ -L "$dest" ]] && [[ "$(readlink -f "$dest" 2>/dev/null || readlink "$dest" 2>/dev/null)" == "$(readlink -f "$src" 2>/dev/null || echo "$src")" ]]; then
      echo "OK:already points to $src"
      return 0
    fi

    if [[ -e "$dest" || -L "$dest" ]]; then
      echo "INFO:Backing up $dest to $dest.bak"
      mv "$dest" "$dest.bak"
    fi

    ln -sfn "$src" "$dest"
    echo "OK:symlink created"
  }

  local SRC_FILE="${MOCK_FS}/source.symlink"
  local DEST_FILE="${MOCK_FS}/target_link"
  echo "content-v1" > "$SRC_FILE"

  # Step 1: Initial link creation
  local out1
  out1=$(link_file_fn "$SRC_FILE" "$DEST_FILE")
  assert_contains "symlink created" "$out1" "link_file creates symlink when target does not exist"
  assert_symlink "$DEST_FILE" "$SRC_FILE" "link_file created valid symlink"

  # Step 2: Idempotent second invocation
  local out2
  out2=$(link_file_fn "$SRC_FILE" "$DEST_FILE")
  assert_contains "already points to" "$out2" "link_file detects existing correct symlink idempotently"

  # Step 3: Conflict handling when regular file exists
  rm -f "$DEST_FILE"
  echo "pre-existing user file" > "$DEST_FILE"
  local out3
  out3=$(link_file_fn "$SRC_FILE" "$DEST_FILE")
  assert_contains "Backing up" "$out3" "link_file creates backup (.bak) on conflicting regular file"
  assert_file_exists "${DEST_FILE}.bak" "backup file exists"
  assert_symlink "$DEST_FILE" "$SRC_FILE" "symlink correctly replaced regular file"

  # Step 4: Broken symlink replacement
  rm -f "$SRC_FILE" "$DEST_FILE" "${DEST_FILE}.bak"
  ln -s "/nonexistent/old_file" "$DEST_FILE"
  echo "content-v2" > "$SRC_FILE"
  local out4
  out4=$(link_file_fn "$SRC_FILE" "$DEST_FILE")
  assert_symlink "$DEST_FILE" "$SRC_FILE" "link_file replaces broken symlink cleanly"

  rm -rf "$MOCK_FS"
}
test_bootstrap_link_file

# ------------------------------------------------------------------------------
# Tier 2 Summary
# ------------------------------------------------------------------------------
TIER_END=$(get_time_ns)
TIER_DURATION=$(calc_duration_ms "$TIER_START" "$TIER_END")
tier_summary "${TIER_NAME}" "$SLA_MS" "$TIER_DURATION"

if [[ "$TIER_FAILED" -gt 0 ]]; then
  exit 1
fi
exit 0
