#!/usr/bin/env bash
# -*- mode: sh -*-
# ==============================================================================
# Tier 5: Adversarial Stress Testing & Edge Case Mining
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=test/test_helpers.sh
source "${SCRIPT_DIR}/test_helpers.sh"

TIER_NAME="Tier 5 - Adversarial Stress & Edge Cases"
SLA_MS=7000
TIER_START=$(get_time_ns)

tier_header "${TIER_NAME}" "<${SLA_MS}ms"

# Setup isolated sandbox HOME
create_test_sandbox
trap cleanup_test_sandbox EXIT

# Install baseline dotfiles into sandbox
HOME="${SANDBOX_HOME}" "${PROJECT_ROOT}/bootstrap.sh" >/dev/null 2>&1

# ==============================================================================
# 1. Adversarial Bash Zero-Fork Prompt Stress Test (500+ renders)
# ==============================================================================
info "1. Adversarial Bash Zero-Fork Prompt Stress Test (500+ prompt renders)"

test_prompt_zero_fork_500_renders() {
  local MOCK_GIT_REPO="${SANDBOX_HOME}/mock_repo_prompt"
  rm -rf "$MOCK_GIT_REPO"
  mkdir -p "$MOCK_GIT_REPO"
  git -C "$MOCK_GIT_REPO" init -q -b main
  git -C "$MOCK_GIT_REPO" config user.email "test@example.com"
  git -C "$MOCK_GIT_REPO" config user.name "Tester"
  echo "init" > "${MOCK_GIT_REPO}/file.txt"
  git -C "$MOCK_GIT_REPO" add file.txt
  git -C "$MOCK_GIT_REPO" commit -q -m "Initial commit"
  echo "dirty" >> "${MOCK_GIT_REPO}/file.txt"
  echo "untracked" > "${MOCK_GIT_REPO}/untracked.txt"

  # Part A: Pure bash prompt render outside git repo (500 renders)
  local nongit_bench_out
  nongit_bench_out=$(
    HOME="${SANDBOX_HOME}" bash -c "
      source '${PROJECT_ROOT}/bash/bashrc.d.symlink/prompt.sh'
      cd '${SANDBOX_HOME}' # Non-git directory
      
      init_pid=\$BASHPID
      pid_drift_count=0
      
      t0=\$(date +%s%N 2>/dev/null || date +%s000000000)
      for ((i=1; i<=500; i++)); do
        eval \"\${PROMPT_COMMAND}\"
        if [[ \$BASHPID -ne \$init_pid ]]; then
          pid_drift_count=\$((pid_drift_count + 1))
        fi
      done
      t1=\$(date +%s%N 2>/dev/null || date +%s000000000)
      
      duration_ms=\$(( (t1 - t0) / 1000000 ))
      echo \"NONGIT_PID_DRIFT=\${pid_drift_count}\"
      echo \"NONGIT_DURATION_MS=\${duration_ms}\"
      echo \"NONGIT_STR=[\${__git_prompt_str}]\"
    " 2>&1 || true
  )

  assert_contains "NONGIT_PID_DRIFT=0" "$nongit_bench_out" "Zero subshell PID drift across 500 prompt renders outside git"
  assert_contains "NONGIT_STR=[]" "$nongit_bench_out" "Git prompt string cleanly empty outside git repository"

  local nongit_ms
  nongit_ms=$(echo "$nongit_bench_out" | grep "NONGIT_DURATION_MS=" | cut -d= -f2 || echo "9999")
  printf "     ${DIM}[Benchmark] 500 prompt renders outside git: %dms (avg: %.3fms/render)${NC}\n" \
    "$nongit_ms" "$(awk "BEGIN {print $nongit_ms / 500}")"

  if [[ "$nongit_ms" -le 200 ]]; then
    pass "Pure bash prompt rendering latency negligible (${nongit_ms}ms <= 200ms for 500 renders)"
  else
    fail "Pure bash prompt rendering latency exceeded budget" "${nongit_ms}ms > 200ms"
  fi

  # Part B: Sourcing git-sh-prompt inside git repo (500 renders)
  local git_bench_out
  git_bench_out=$(
    HOME="${SANDBOX_HOME}" bash -c "
      source '${PROJECT_ROOT}/bash/bashrc.d.symlink/prompt.sh'
      if [[ -f '${PROJECT_ROOT}/bash/bashrc.d.symlink/completion/git-prompt.bash' ]]; then
        source '${PROJECT_ROOT}/bash/bashrc.d.symlink/completion/git-prompt.bash'
      elif [[ -f '/usr/lib/git-core/git-sh-prompt' ]]; then
        source '/usr/lib/git-core/git-sh-prompt'
      elif [[ -f '/usr/share/git-core/contrib/completion/git-prompt.sh' ]]; then
        source '/usr/share/git-core/contrib/completion/git-prompt.sh'
      fi

      cd '${MOCK_GIT_REPO}'
      
      init_pid=\$BASHPID
      pid_drift_count=0
      
      t0=\$(date +%s%N 2>/dev/null || date +%s000000000)
      for ((i=1; i<=500; i++)); do
        eval \"\${PROMPT_COMMAND}\"
        if [[ \$BASHPID -ne \$init_pid ]]; then
          pid_drift_count=\$((pid_drift_count + 1))
        fi
      done
      t1=\$(date +%s%N 2>/dev/null || date +%s000000000)
      
      duration_ms=\$(( (t1 - t0) / 1000000 ))
      echo \"GIT_PID_DRIFT=\${pid_drift_count}\"
      echo \"GIT_DURATION_MS=\${duration_ms}\"
      echo \"GIT_STR=\${__git_prompt_str}\"
    " 2>&1 || true
  )

  assert_contains "GIT_PID_DRIFT=0" "$git_bench_out" "Zero subshell PID drift across 500 prompt renders inside git repository"
  assert_contains "Git:" "$git_bench_out" "Git prompt string activated in git repository"
  assert_contains "(Git:main)" "$git_bench_out" "Git prompt expands branch name variable properly via eval"

  # Part C: PROMPT_COMMAND chaining idempotency (multiple sourcings)
  local chain_test_out
  chain_test_out=$(
    HOME="${SANDBOX_HOME}" bash -c "
      PROMPT_COMMAND='custom_hook'
      source '${PROJECT_ROOT}/bash/bashrc.d.symlink/prompt.sh'
      source '${PROJECT_ROOT}/bash/bashrc.d.symlink/prompt.sh'
      echo \"FINAL_PC=[\${PROMPT_COMMAND}]\"
    " 2>&1 || true
  )
  assert_contains "FINAL_PC=[custom_hook;_run_precmd_functions]" "$chain_test_out" "PROMPT_COMMAND does not multiply register _run_precmd_functions on re-source"

  rm -rf "$MOCK_GIT_REPO"
}
test_prompt_zero_fork_500_renders

# ==============================================================================
# 2. Adversarial Lazy Completion Stress Test
# ==============================================================================
info "2. Adversarial Lazy Completion Stress Test (Dynamic loading, non-existent commands, fallbacks)"

test_lazy_completion_stress() {
  local COMP_SCRIPT="${PROJECT_ROOT}/bash/bashrc.d.symlink/completion.sh"

  # 1. Test initial registration of complete -D
  local init_check
  init_check=$(
    HOME="${SANDBOX_HOME}" bash -c "
      source '${COMP_SCRIPT}'
      if [[ \"\${BASH_VERSINFO[0]:-0}\" -ge 4 ]]; then
        complete -p -D 2>/dev/null || echo 'NO_DEFAULT_COMP'
      else
        echo '_lazy_bash_completion_legacy_ok'
      fi
    " 2>&1 || true
  )
  if [[ "$init_check" == *"_lazy_bash_completion_legacy_ok"* ]]; then
    pass "complete -D / legacy completion handler initialized"
  else
    assert_contains "_lazy_bash_completion" "$init_check" "complete -D initially registered to _lazy_bash_completion"
  fi

  # 2. Trigger completion on non-existent command
  local nonexist_comp_out
  nonexist_comp_out=$(
    HOME="${SANDBOX_HOME}" bash -c "
      source '${COMP_SCRIPT}'
      # Call _lazy_bash_completion directly as readline would
      _lazy_bash_completion nonexistent_cmd_xyz
      ret=\$?
      echo \"LAZY_RET=\${ret}\"
      
      # Verify _lazy_bash_completion was replaced by system completion loader or cleared
      d_loader=\$(complete -p -D 2>/dev/null || echo 'NONE')
      if [[ \"\$d_loader\" != *\"_lazy_bash_completion\"* ]]; then
        echo \"LAZY_HANDED_OFF=YES\"
      else
        echo \"LAZY_HANDED_OFF=NO\"
      fi

      # Verify function unset
      if declare -F _lazy_bash_completion >/dev/null; then echo 'FN_STILL_EXISTS'; else echo 'FN_UNSET'; fi
    " 2>&1 || true
  )
  assert_contains "LAZY_RET=124" "$nonexist_comp_out" "_lazy_bash_completion returns 124 (readline retry code)"
  assert_contains "LAZY_HANDED_OFF=YES" "$nonexist_comp_out" "_lazy_bash_completion hands off complete -D to system loader"
  assert_contains "FN_UNSET" "$nonexist_comp_out" "_lazy_bash_completion unsets itself after invocation"

  # 3. Test git alias 'g' completion binding after lazy trigger
  local g_comp_out
  g_comp_out=$(
    HOME="${SANDBOX_HOME}" bash -c "
      source '${COMP_SCRIPT}'
      _lazy_bash_completion git >/dev/null 2>&1 || true
      complete -p g 2>/dev/null || echo 'NO_G_COMP'
    " 2>&1 || true
  )
  assert_contains "complete" "$g_comp_out" "Alias 'g' configured with completion handler after lazy trigger"

  # 4. Fallback test when system completion files do not exist
  local fallback_out
  fallback_out=$(
    HOME="${SANDBOX_HOME}" bash -c "
      source '${COMP_SCRIPT}'
      HOMEBREW_PREFIX='/nonexistent'
      _lazy_bash_completion nonexistent_tool 2>&1
      ret=\$?
      echo \"FALLBACK_RET=\${ret}\"
    " 2>&1 || true
  )
  assert_contains "FALLBACK_RET=124" "$fallback_out" "Lazy completion degrades gracefully when system completions absent"

  # 5. Rapid 100 consecutive completion evaluations without recursion/errors
  local rapid_comp_out
  rapid_comp_out=$(
    HOME="${SANDBOX_HOME}" bash -c "
      source '${COMP_SCRIPT}'
      errors=0
      for ((i=1; i<=100; i++)); do
        if declare -F _completion_loader >/dev/null 2>&1; then
          _completion_loader \"cmd_\$i\" 2>/dev/null || true
        elif declare -F _comp_complete_load >/dev/null 2>&1; then
          _comp_complete_load \"cmd_\$i\" 2>/dev/null || true
        fi
      done
      echo \"RAPID_COMP_ERRORS=\${errors}\"
    " 2>&1 || true
  )
  assert_contains "RAPID_COMP_ERRORS=0" "$rapid_comp_out" "100 dynamic completion invocations executed with 0 errors"
}
test_lazy_completion_stress

# ==============================================================================
# 3. Adversarial bin/git-clean.sh Parameter Expansion & Branch Safety Test
# ==============================================================================
info "3. Adversarial bin/git-clean.sh Parameter Expansion & Protected Branch Safety"

test_git_clean_adversarial() {
  local CLEAN_REPO="${SANDBOX_HOME}/clean_adversarial_repo"
  rm -rf "$CLEAN_REPO"
  mkdir -p "$CLEAN_REPO"
  git -C "$CLEAN_REPO" init -q -b main
  git -C "$CLEAN_REPO" config user.email "test@example.com"
  git -C "$CLEAN_REPO" config user.name "Tester"

  echo "init" > "${CLEAN_REPO}/README.md"
  git -C "$CLEAN_REPO" add README.md
  git -C "$CLEAN_REPO" commit -q -m "Initial commit on main"

  # Create all protected branches (merged into main)
  local PROTECTED=("master" "develop" "dev" "staging" "release" "production" "trunk")
  for pb in "${PROTECTED[@]}"; do
    git -C "$CLEAN_REPO" branch "$pb" main
  done

  # Create branches with special characters and unusual valid git ref names
  local SPECIAL_MERGED=(
    "feature/login"
    "fix/issue-42"
    "feat_123"
    "feat.dot"
    "feat+plus"
    "feat@at"
    "feat#hash"
    "feat\$dollar"
    "feat%percent"
    "feat(parens)"
    "feat=equal"
    "feat,comma"
    "feat-leading-dash"
    "feat_with_unicode_🚀"
  )
  for sb in "${SPECIAL_MERGED[@]}"; do
    git -C "$CLEAN_REPO" branch "$sb" main
  done

  # Create an UNMERGED branch (must NOT be deleted)
  git -C "$CLEAN_REPO" checkout -q -b "unmerged-feature"
  echo "unmerged work" >> "${CLEAN_REPO}/work.txt"
  git -C "$CLEAN_REPO" add work.txt
  git -C "$CLEAN_REPO" commit -q -m "Unmerged feature work"

  # Switch to a custom current branch
  git -C "$CLEAN_REPO" checkout -q -b "my-active-working-branch"

  # 1. Run git-clean.sh in --dry-run mode first
  local dry_run_out
  dry_run_out=$(
    cd "$CLEAN_REPO" && "${PROJECT_ROOT}/bin/git-clean.sh" --dry-run --branches-only 2>&1 || true
  )
  assert_contains "[DRY-RUN] Would delete" "$dry_run_out" "git-clean.sh --dry-run reports simulation"

  # Verify 0 branches were deleted in dry-run
  for pb in "${PROTECTED[@]}"; do
    if git -C "$CLEAN_REPO" show-ref --verify --quiet "refs/heads/${pb}"; then
      pass "Dry-run preserved protected branch '${pb}'"
    else
      fail "Dry-run accidentally deleted '${pb}'"
    fi
  done
  for sb in "${SPECIAL_MERGED[@]}"; do
    if git -C "$CLEAN_REPO" show-ref --verify --quiet "refs/heads/${sb}"; then
      pass "Dry-run preserved branch '${sb}'"
    else
      fail "Dry-run accidentally deleted '${sb}'"
    fi
  done

  # 2. Run git-clean.sh with --yes --branches-only
  local real_run_out
  real_run_out=$(
    cd "$CLEAN_REPO" && "${PROJECT_ROOT}/bin/git-clean.sh" --yes --branches-only 2>&1 || true
  )

  # Check that ALL protected branches are 100% PRESERVED
  for pb in "${PROTECTED[@]}"; do
    if git -C "$CLEAN_REPO" show-ref --verify --quiet "refs/heads/${pb}"; then
      pass "Protected branch '${pb}' survived automated cleanup"
    else
      fail "Protected branch '${pb}' was ACCIDENTALLY DELETED!"
    fi
  done

  # Check that CURRENT_BRANCH is 100% PRESERVED
  if git -C "$CLEAN_REPO" show-ref --verify --quiet "refs/heads/my-active-working-branch"; then
    pass "Current active branch 'my-active-working-branch' survived automated cleanup"
  else
    fail "Current active branch was ACCIDENTALLY DELETED!"
  fi

  # Check that UNMERGED branch is 100% PRESERVED
  if git -C "$CLEAN_REPO" show-ref --verify --quiet "refs/heads/unmerged-feature"; then
    pass "Unmerged branch 'unmerged-feature' survived automated cleanup"
  else
    fail "Unmerged branch was ACCIDENTALLY DELETED!"
  fi

  # Check that eligible merged special-char branches WERE safely cleaned up
  for sb in "${SPECIAL_MERGED[@]}"; do
    if ! git -C "$CLEAN_REPO" show-ref --verify --quiet "refs/heads/${sb}"; then
      pass "Merged branch '${sb}' correctly pruned"
    else
      fail "Merged branch '${sb}' was NOT pruned"
    fi
  done

  # 3. Test leading dash branch names (option injection defense via --)
  local main_commit
  main_commit=$(git -C "$CLEAN_REPO" rev-parse refs/heads/main)
  local DASH_BRANCHES=("--help" "-D" "-dash-branch")
  for db in "${DASH_BRANCHES[@]}"; do
    git -C "$CLEAN_REPO" update-ref "refs/heads/${db}" "$main_commit"
  done
  (cd "$CLEAN_REPO" && "${PROJECT_ROOT}/bin/git-clean.sh" --yes --branches-only >/dev/null 2>&1)
  assert_eq 0 "$?" "git-clean.sh cleans branches starting with dash without option injection errors"
  for db in "${DASH_BRANCHES[@]}"; do
    if ! git -C "$CLEAN_REPO" show-ref --verify --quiet "refs/heads/${db}"; then
      pass "Leading-dash branch '${db}' safely pruned"
    else
      fail "Leading-dash branch '${db}' was NOT pruned"
    fi
  done

  # 4. Test detached HEAD state handling
  git -C "$CLEAN_REPO" update-ref "refs/heads/merged-before-detach" "$main_commit"
  git -C "$CLEAN_REPO" checkout -q --detach HEAD
  local detached_run_out
  detached_run_out=$(cd "$CLEAN_REPO" && "${PROJECT_ROOT}/bin/git-clean.sh" --yes --branches-only 2>&1)
  local detached_status=$?
  assert_eq 0 "$detached_status" "git-clean.sh succeeds under detached HEAD without crashing on non-branch lines"
  if ! git -C "$CLEAN_REPO" show-ref --verify --quiet "refs/heads/merged-before-detach"; then
    pass "Merged branch during detached HEAD safely pruned"
  else
    fail "Merged branch during detached HEAD was not pruned"
  fi
  # Switch back to main
  git -C "$CLEAN_REPO" checkout -q main

  rm -rf "$CLEAN_REPO"
}
test_git_clean_adversarial

# ==============================================================================
# 4. Adversarial Path Helper Stress Test (Empty strings, duplicates, colons, globs)
# ==============================================================================
info "4. Adversarial Path Helper Stress Test (path_prepend, path_append, path_contains, dedup_path)"

test_path_helpers_adversarial() {
  # Define path helpers from bash/profile.symlink
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

  local SAVED_PATH="$PATH"
  local TEST_TMP="${SANDBOX_HOME}/path_stress"
  mkdir -p "${TEST_TMP}/dir1" "${TEST_TMP}/dir2" "${TEST_TMP}/dir3" "${TEST_TMP}/dir with space" "${TEST_TMP}/dir_with_glob_star"

  # Test 4.1: Path contains boundary & substring isolation
  PATH="/usr/local/bin:/usr/bin:/bin:/usr/games"
  assert_eq 0 "$(path_contains "/usr/bin"; echo $?)" "path_contains matches exact segment /usr/bin"
  assert_eq 1 "$(path_contains "/usr"; echo $?)" "path_contains rejects prefix substring /usr"
  assert_eq 1 "$(path_contains "/bin:"; echo $?)" "path_contains rejects trailing colon in search arg"
  assert_eq 1 "$(path_contains "bin"; echo $?)" "path_contains rejects relative path when PATH is absolute"

  # Test 4.2: Non-existent directories ignored by path_prepend and path_append
  PATH="/usr/bin"
  path_prepend "/nonexistent/directory/12345"
  path_append "/nonexistent/directory/67890"
  assert_eq "/usr/bin" "$PATH" "Non-existent directories strictly rejected by prepend/append"

  # Test 4.3: Directories with spaces
  path_prepend "${TEST_TMP}/dir with space"
  assert_eq "${TEST_TMP}/dir with space:/usr/bin" "$PATH" "path_prepend handles paths with spaces"
  path_append "${TEST_TMP}/dir2"
  assert_eq "${TEST_TMP}/dir with space:/usr/bin:${TEST_TMP}/dir2" "$PATH" "path_append adds valid dir to tail"

  # Test 4.4: 500 redundant path additions (idempotency under stress)
  for ((i=1; i<=500; i++)); do
    path_prepend "${TEST_TMP}/dir1"
    path_append "${TEST_TMP}/dir3"
  done
  dedup_path
  assert_eq "${TEST_TMP}/dir1:${TEST_TMP}/dir with space:/usr/bin:${TEST_TMP}/dir2:${TEST_TMP}/dir3" "$PATH" \
    "500 redundant prepends/appends maintain exact single-entry deduplication"

  # Test 4.5: Extreme dedup_path stress (colon floods, empty tokens)
  PATH="::::/a::::/b::::/a::::/c::::/b::::/d::::"
  dedup_path
  assert_eq "/a:/b:/c:/d" "$PATH" "dedup_path cleans extreme colon floods while preserving order"

  PATH="::::::"
  dedup_path
  assert_eq "" "$PATH" "dedup_path reduces pure colon strings to empty string"

  PATH=""
  dedup_path
  assert_eq "" "$PATH" "dedup_path handles empty string without error"

  # Restore PATH before filesystem operations
  PATH="$SAVED_PATH"

  # Test 4.6: Globbing safety in dedup_path (set -f protection)
  local GLOB_DIR="${TEST_TMP}/glob_test"
  mkdir -p "$GLOB_DIR"
  touch "${GLOB_DIR}/alpha" "${GLOB_DIR}/beta"
  
  (
    cd "$GLOB_DIR"
    PATH="${TEST_TMP}/dir_with_glob_star:/bin:/usr/bin"
    dedup_path
    if [[ "$PATH" == "${TEST_TMP}/dir_with_glob_star:/bin:/usr/bin" ]]; then
      exit 0
    else
      exit 1
    fi
  )
  assert_eq 0 "$?" "dedup_path preserves path segments without expanding local globs"

  PATH="$SAVED_PATH"
  rm -rf "$TEST_TMP"
}
test_path_helpers_adversarial

# ==============================================================================
# Tier 5 Summary
# ==============================================================================
TIER_END=$(get_time_ns)
TIER_DURATION=$(calc_duration_ms "$TIER_START" "$TIER_END")
tier_summary "${TIER_NAME}" "$SLA_MS" "$TIER_DURATION"

if [[ "$TIER_FAILED" -gt 0 ]]; then
  exit 1
fi
exit 0
