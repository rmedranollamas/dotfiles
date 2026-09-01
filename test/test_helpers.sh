#!/usr/bin/env bash
# -*- mode: sh -*-
# ==============================================================================
# test_helpers.sh - Shared assertions, timing utilities, and test harness library
# ==============================================================================

# Ensure pipefail and robust execution when sourced
set -eo pipefail

# Determine project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd -P)"
export PROJECT_ROOT

# Color codes
if [[ -t 1 || "${FORCE_COLOR:-0}" == "1" ]]; then
  GREEN='\033[0;32m'
  RED='\033[0;31m'
  BLUE='\033[0;34m'
  CYAN='\033[0;36m'
  YELLOW='\033[1;33m'
  MAGENTA='\033[0;35m'
  BOLD='\033[1m'
  DIM='\033[2m'
  NC='\033[0m'
else
  GREEN=''
  RED=''
  BLUE=''
  CYAN=''
  YELLOW=''
  MAGENTA=''
  BOLD=''
  DIM=''
  NC=''
fi

# Counters
TOTAL_PASSED=0
TOTAL_FAILED=0
TOTAL_SKIPPED=0

TIER_PASSED=0
TIER_FAILED=0
TIER_SKIPPED=0

# High-resolution time measurement (nanoseconds to milliseconds)
get_time_ns() {
  date +%s%N 2>/dev/null || date +%s000000000
}

calc_duration_ms() {
  local start_ns="$1"
  local end_ns="$2"
  if [[ "$start_ns" =~ ^[0-9]+$ ]] && [[ "$end_ns" =~ ^[0-9]+$ ]] && [[ "$end_ns" -ge "$start_ns" ]]; then
    echo $(( (end_ns - start_ns) / 1000000 ))
  else
    echo "0"
  fi
}

# Logging & status helpers
pass() {
  local test_name="$1"
  TIER_PASSED=$((TIER_PASSED + 1))
  TOTAL_PASSED=$((TOTAL_PASSED + 1))
  printf "  [ ${GREEN}PASS${NC} ] %s\n" "$test_name"
}

fail() {
  local test_name="$1"
  local reason="${2:-assertion failed}"
  TIER_FAILED=$((TIER_FAILED + 1))
  TOTAL_FAILED=$((TOTAL_FAILED + 1))
  printf "  [ ${RED}FAIL${NC} ] %s: %s\n" "$test_name" "$reason"
}

skip() {
  local test_name="$1"
  local reason="${2:-skipped}"
  TIER_SKIPPED=$((TIER_SKIPPED + 1))
  TOTAL_SKIPPED=$((TOTAL_SKIPPED + 1))
  printf "  [ ${YELLOW}SKIP${NC} ] %s: %s\n" "$test_name" "$reason"
}

info() {
  printf "${BOLD}${BLUE}==> %s${NC}\n" "$1"
}

tier_header() {
  local title="$1"
  local sla="$2"
  printf "\n%b%s\n" "${BOLD}${CYAN}" "------------------------------------------------------"
  printf " %s (SLA: %s)\n" "$title" "$sla"
  printf "%s%b\n" "------------------------------------------------------" "${NC}"
}

tier_summary() {
  local tier_name="$1"
  local sla_ms="$2"
  local duration_ms="$3"
  
  local sla_status="${GREEN}MET${NC}"
  if [[ "$duration_ms" -gt "$sla_ms" ]]; then
    sla_status="${YELLOW}EXCEEDED (${duration_ms}ms > ${sla_ms}ms)${NC}"
  fi

  printf "  ${DIM}%s Summary: %d passed, %d failed, %d skipped (%d ms, SLA: %s)${NC}\n" \
    "$tier_name" "$TIER_PASSED" "$TIER_FAILED" "$TIER_SKIPPED" "$duration_ms" "$sla_status"
}

# Assertion primitives
assert_eq() {
  local expected="$1"
  local actual="$2"
  local desc="$3"

  if [[ "$expected" == "$actual" ]]; then
    pass "$desc"
  else
    fail "$desc" "expected '$expected', got '$actual'"
  fi
}

assert_ne() {
  local unexpected="$1"
  local actual="$2"
  local desc="$3"

  if [[ "$unexpected" != "$actual" ]]; then
    pass "$desc"
  else
    fail "$desc" "value unexpectedly equaled '$unexpected'"
  fi
}

assert_contains() {
  local needle="$1"
  local haystack="$2"
  local desc="$3"

  if [[ "$haystack" == *"$needle"* ]]; then
    pass "$desc"
  else
    fail "$desc" "output did not contain '$needle'"
  fi
}

assert_match() {
  local pattern="$1"
  local string="$2"
  local desc="$3"

  if [[ "$string" =~ $pattern ]]; then
    pass "$desc"
  else
    fail "$desc" "string '$string' did not match pattern '$pattern'"
  fi
}

assert_exit_code() {
  local expected_code="$1"
  local actual_code="$2"
  local desc="$3"

  if [[ "$expected_code" -eq "$actual_code" ]]; then
    pass "$desc"
  else
    fail "$desc" "expected exit code $expected_code, got $actual_code"
  fi
}

assert_file_exists() {
  local file_path="$1"
  local desc="${2:-file $file_path exists}"

  if [[ -f "$file_path" ]]; then
    pass "$desc"
  else
    fail "$desc" "file not found at $file_path"
  fi
}

assert_dir_exists() {
  local dir_path="$1"
  local desc="${2:-directory $dir_path exists}"

  if [[ -d "$dir_path" ]]; then
    pass "$desc"
  else
    fail "$desc" "directory not found at $dir_path"
  fi
}

assert_symlink() {
  local link_path="$1"
  local expected_target="$2"
  local desc="$3"

  if [[ ! -L "$link_path" ]]; then
    fail "$desc" "not a symlink: $link_path"
    return
  fi

  local actual_target
  actual_target="$(readlink "$link_path" 2>/dev/null || true)"
  local actual_canonical
  actual_canonical="$(readlink -f "$link_path" 2>/dev/null || true)"
  local expected_canonical
  expected_canonical="$(readlink -f "$expected_target" 2>/dev/null || echo "$expected_target")"

  if [[ "$actual_target" == "$expected_target" || "$actual_canonical" == "$expected_canonical" ]]; then
    pass "$desc"
  else
    fail "$desc" "symlink points to '$actual_target', expected '$expected_target'"
  fi
}

# Sandbox isolation helpers
create_test_sandbox() {
  SANDBOX_HOME="$(mktemp -d -t dotfiles_sandbox_XXXXXX 2>/dev/null || mktemp -d "/tmp/dotfiles_sandbox_XXXXXX")"
  export SANDBOX_HOME
}

cleanup_test_sandbox() {
  if [[ -n "${SANDBOX_HOME:-}" && -d "$SANDBOX_HOME" && "$SANDBOX_HOME" == *"/dotfiles_sandbox_"* ]]; then
    rm -rf "$SANDBOX_HOME"
    unset SANDBOX_HOME
  fi
}
