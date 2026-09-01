#!/usr/bin/env bash
# -*- mode: sh -*-
# ==============================================================================
# test_dotfiles.sh - Unified Master Test Runner for Dotfiles Test Suite
#
# Architecture:
#   Tier 1: Static & Syntax Validation      (SLA: <200ms)
#   Tier 2: Unit & Component Isolation     (SLA: <500ms)
#   Tier 3: Integration & Sandbox E2E      (SLA: <1.5s)
#   Tier 4: Performance & Benchmarking     (SLA: <2.0s)
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd -P)"
export PROJECT_ROOT

# shellcheck source=test/test_helpers.sh
source "${SCRIPT_DIR}/test_helpers.sh"

RUN_TIER1=true
RUN_TIER2=true
RUN_TIER3=true
RUN_TIER4=true
VERBOSE=false

show_help() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Unified test runner for the 4-tier dotfiles validation harness.

Options:
  -1, --tier-1       Run Tier 1 only (Static & Syntax Validation)
  -2, --tier-2       Run Tier 2 only (Unit & Component Isolation)
  -3, --tier-3       Run Tier 3 only (Integration & Sandbox E2E)
  -4, --tier-4       Run Tier 4 only (Performance & Benchmarking)
  -a, --all          Run all 4 tiers (default)
  -l, --list         List available test tiers and their SLAs
  -v, --verbose      Enable verbose output
  -h, --help         Display this help message and exit

SLA Targets:
  Tier 1: < 200 ms
  Tier 2: < 500 ms
  Tier 3: < 1500 ms
  Tier 4: < 2000 ms
  Total:  < 2000 ms (full parallel/optimized run)
EOF
  exit 0
}

list_tiers() {
  cat <<EOF
Available Test Tiers:
  [1] Tier 1: Static & Syntax Validation (bash -n, Emacs sexp, SSH config, symlink presence, perms) [SLA: <200ms]
  [2] Tier 2: Unit & Component Isolation (profile paths, aliases cascades, git-clean, epylint, link_file) [SLA: <500ms]
  [3] Tier 3: Integration & Sandbox E2E (sandbox bootstrap, target mappings, idempotency, bash -i, tmux, SSH) [SLA: <1.5s]
  [4] Tier 4: Performance & Benchmarking (bash startup <40ms, fork audit, emacs latency, harness SLA) [SLA: <2.0s]
EOF
  exit 0
}

# Parse command line options
if [[ $# -gt 0 ]]; then
  RUN_TIER1=false
  RUN_TIER2=false
  RUN_TIER3=false
  RUN_TIER4=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -1|--tier-1)
        RUN_TIER1=true
        shift
        ;;
      -2|--tier-2)
        RUN_TIER2=true
        shift
        ;;
      -3|--tier-3)
        RUN_TIER3=true
        shift
        ;;
      -4|--tier-4)
        RUN_TIER4=true
        shift
        ;;
      -a|--all)
        RUN_TIER1=true
        RUN_TIER2=true
        RUN_TIER3=true
        RUN_TIER4=true
        shift
        ;;
      -l|--list)
        list_tiers
        ;;
      -v|--verbose)
        VERBOSE=true
        shift
        ;;
      -h|--help)
        show_help
        ;;
      *)
        echo "Unknown option: $1" >&2
        show_help
        ;;
    esac
  done
fi

SUITE_START=$(get_time_ns)

printf "\n%b" "${BOLD}${MAGENTA}"
printf "%s\n" "======================================================"
printf "%s\n" "           DOTFILES AUTOMATED TEST SUITE              "
printf "%s\n" "======================================================"
printf "%b\n" "${NC}"

TOTAL_PASSED=0
TOTAL_FAILED=0
TOTAL_SKIPPED=0

TIER1_STATUS="SKIPPED"
TIER2_STATUS="SKIPPED"
TIER3_STATUS="SKIPPED"
TIER4_STATUS="SKIPPED"

TIER1_MS=0
TIER2_MS=0
TIER3_MS=0
TIER4_MS=0

# Execute Tier 1
if [[ "$RUN_TIER1" == true ]]; then
  t1_start=$(get_time_ns)
  if bash "${SCRIPT_DIR}/tier1_static.sh"; then
    TIER1_STATUS="${GREEN}PASSED${NC}"
  else
    TIER1_STATUS="${RED}FAILED${NC}"
    TOTAL_FAILED=$((TOTAL_FAILED + 1))
  fi
  t1_end=$(get_time_ns)
  TIER1_MS=$(calc_duration_ms "$t1_start" "$t1_end")
fi

# Execute Tier 2
if [[ "$RUN_TIER2" == true ]]; then
  t2_start=$(get_time_ns)
  if bash "${SCRIPT_DIR}/tier2_unit.sh"; then
    TIER2_STATUS="${GREEN}PASSED${NC}"
  else
    TIER2_STATUS="${RED}FAILED${NC}"
    TOTAL_FAILED=$((TOTAL_FAILED + 1))
  fi
  t2_end=$(get_time_ns)
  TIER2_MS=$(calc_duration_ms "$t2_start" "$t2_end")
fi

# Execute Tier 3
if [[ "$RUN_TIER3" == true ]]; then
  t3_start=$(get_time_ns)
  if bash "${SCRIPT_DIR}/tier3_integration.sh"; then
    TIER3_STATUS="${GREEN}PASSED${NC}"
  else
    TIER3_STATUS="${RED}FAILED${NC}"
    TOTAL_FAILED=$((TOTAL_FAILED + 1))
  fi
  t3_end=$(get_time_ns)
  TIER3_MS=$(calc_duration_ms "$t3_start" "$t3_end")
fi

# Execute Tier 4
if [[ "$RUN_TIER4" == true ]]; then
  t4_start=$(get_time_ns)
  if bash "${SCRIPT_DIR}/tier4_perf.sh"; then
    TIER4_STATUS="${GREEN}PASSED${NC}"
  else
    TIER4_STATUS="${RED}FAILED${NC}"
    TOTAL_FAILED=$((TOTAL_FAILED + 1))
  fi
  t4_end=$(get_time_ns)
  TIER4_MS=$(calc_duration_ms "$t4_start" "$t4_end")
fi

SUITE_END=$(get_time_ns)
TOTAL_DURATION=$(calc_duration_ms "$SUITE_START" "$SUITE_END")

# Print Executive Summary Table
printf "\n%b" "${BOLD}${CYAN}"
printf "%s\n" "======================================================"
printf "%s\n" "                 TEST SUITE SUMMARY                   "
printf "%s\n" "======================================================"
printf "%b" "${NC}"

format_row() {
  local name="$1"
  local status="$2"
  local duration="$3"
  local sla="$4"
  printf "  %-32s %-16b %6sms (SLA: %s)\n" "$name" "$status" "$duration" "$sla"
}

[[ "$RUN_TIER1" == true ]] && format_row "Tier 1: Static & Syntax" "$TIER1_STATUS" "$TIER1_MS" "<200ms"
[[ "$RUN_TIER2" == true ]] && format_row "Tier 2: Unit & Isolation" "$TIER2_STATUS" "$TIER2_MS" "<500ms"
[[ "$RUN_TIER3" == true ]] && format_row "Tier 3: Integration & E2E" "$TIER3_STATUS" "$TIER3_MS" "<1.5s"
[[ "$RUN_TIER4" == true ]] && format_row "Tier 4: Perf & Benchmarks" "$TIER4_STATUS" "$TIER4_MS" "<8.0s"

printf "%b%s\n" "${BOLD}${CYAN}" "------------------------------------------------------"
printf "  Total Suite Duration: %d ms\n" "$TOTAL_DURATION"
printf "%s%b\n" "======================================================" "${NC}"

if [[ "$TOTAL_FAILED" -gt 0 ]]; then
  printf "\n%b  [ OVERALL RESULT ]: FAILED (%d tier(s) failed)%b\n\n" "${RED}${BOLD}" "$TOTAL_FAILED" "${NC}"
  exit 1
else
  printf "\n%b  [ OVERALL RESULT ]: ALL TIERS PASSED (100%%)%b\n\n" "${GREEN}${BOLD}" "${NC}"
  exit 0
fi
