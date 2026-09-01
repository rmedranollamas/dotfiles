#!/bin/bash
#
# git-clean.sh - Interactive Git branch and repository cleanup utility
#
# Features:
# - Prunes remote-tracking references
# - Identifies and safely removes merged local branches (protects main/master/develop/current)
# - Performs deep garbage collection and repack
# - Supports --dry-run, --branches-only, --gc-only, and --yes flags

set -eo pipefail
shopt -s extglob

DRY_RUN=false
BRANCHES_ONLY=false
GC_ONLY=false
AUTO_YES=false

PROTECTED_BRANCHES=("main" "master" "develop" "dev" "staging" "release" "production" "trunk")

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -n, --dry-run        Simulate cleanup without making any changes
  -b, --branches-only  Only clean up merged local branches (skip GC/repack)
  -g, --gc-only        Only run repository garbage collection (skip branch cleanup)
  -y, --yes            Run non-interactively, auto-confirming all prompts
  -h, --help           Display this help message

Protected branches: ${PROTECTED_BRANCHES[*]}
EOF
  exit 0
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--dry-run)
      DRY_RUN=true
      shift
      ;;
    -b|--branches-only)
      BRANCHES_ONLY=true
      shift
      ;;
    -g|--gc-only)
      GC_ONLY=true
      shift
      ;;
    -y|--yes)
      AUTO_YES=true
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      ;;
  esac
done

if [[ "${BRANCHES_ONLY}" == true && "${GC_ONLY}" == true ]]; then
  echo "Error: --branches-only and --gc-only are mutually exclusive." >&2
  exit 1
fi

# Ensure inside a git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: $(pwd) is not a Git repository." >&2
  exit 1
fi

CURRENT_BRANCH="$(git branch --show-current 2>/dev/null || echo "")"

# Determine default target branch (e.g. main or master)
get_default_branch() {
  local default_ref
  default_ref="$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || true)"
  default_ref="${default_ref#origin/}"
  if [[ -n "${default_ref}" ]]; then
    echo "${default_ref}"
    return
  fi
  local b
  for b in main master develop trunk; do
    if git show-ref --verify --quiet "refs/heads/${b}"; then
      echo "${b}"
      return
    fi
  done
  echo "main"
}

is_protected() {
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

# Step 1: Branch Cleanup
cleanup_branches() {
  local target_branch
  target_branch="$(get_default_branch)"

  echo "==> Fetching and pruning remote tracking branches..."
  if [[ "${DRY_RUN}" == true ]]; then
    echo "  [DRY-RUN] git fetch --prune --all"
  else
    git fetch --prune --all 2>&1 || git fetch --prune 2>&1 || true
  fi

  echo "==> Inspecting merged local branches against '${target_branch}'..."
  local merged_branches=()
  while IFS= read -r branch; do
    branch="${branch##*([ *])}"
    branch="${branch%%*([[:space:]])}"
    [[ -z "${branch}" || "${branch}" == \(* || "${branch}" == "HEAD" ]] && continue
    if is_protected "${branch}"; then
      continue
    fi
    merged_branches+=("${branch}")
  done < <(git branch --merged "${target_branch}" 2>/dev/null || git branch --merged HEAD 2>/dev/null || true)

  if [[ ${#merged_branches[@]} -eq 0 ]]; then
    echo "  No merged local branches to remove."
    return
  fi

  echo "  Found ${#merged_branches[@]} merged branch(es) eligible for deletion:"
  for b in "${merged_branches[@]}"; do
    echo "    - ${b}"
  done

  if [[ "${DRY_RUN}" == true ]]; then
    echo "  [DRY-RUN] Would delete ${#merged_branches[@]} branch(es)."
    return
  fi

  local do_delete=false
  if [[ "${AUTO_YES}" == true ]]; then
    do_delete=true
  else
    read -r -p "Delete these ${#merged_branches[@]} branch(es)? [y/N] " response
    case "$response" in
      [yY][eE][sS]|[yY]) do_delete=true ;;
      *) do_delete=false ;;
    esac
  fi

  if [[ "${do_delete}" == true ]]; then
    for b in "${merged_branches[@]}"; do
      echo "  Deleting branch '${b}'..."
      git branch -d -- "${b}" 2>/dev/null || git branch -D -- "${b}" 2>/dev/null || true
    done
    echo "  Branch cleanup complete."
  else
    echo "  Skipping branch deletion."
  fi
}

# Step 2: Garbage Collection & Optimization
cleanup_gc() {
  echo "==> Repository Garbage Collection & Optimization..."
  if [[ "${DRY_RUN}" == true ]]; then
    echo "  [DRY-RUN] git reflog expire --expire=now --all"
    echo "  [DRY-RUN] git fsck --full --unreachable"
    echo "  [DRY-RUN] git repack -a -d -l --depth=250"
    echo "  [DRY-RUN] git prune --verbose"
    echo "  [DRY-RUN] git gc --aggressive --prune=now"
    return
  fi

  local do_gc=false
  if [[ "${AUTO_YES}" == true ]]; then
    do_gc=true
  else
    read -r -p "Run aggressive garbage collection and repack? [y/N] " response
    case "$response" in
      [yY][eE][sS]|[yY]) do_gc=true ;;
      *) do_gc=false ;;
    esac
  fi

  if [[ "${do_gc}" == true ]]; then
    echo "  Expiring reflogs..."
    git reflog expire --expire=now --all || true

    echo "  Repacking and pruning unreachable objects..."
    git fsck --full --unreachable >/dev/null 2>&1 || true
    git prune --verbose || true

    echo "  Running aggressive garbage collection..."
    git gc --aggressive --prune=now

    echo "  Repository optimization complete."
  else
    echo "  Skipping repository garbage collection."
  fi
}

# Execution flow
if [[ "${GC_ONLY}" == false ]]; then
  cleanup_branches
  echo ""
fi

if [[ "${BRANCHES_ONLY}" == false ]]; then
  cleanup_gc
  echo ""
fi

echo "==> Done."
