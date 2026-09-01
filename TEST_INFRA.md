# Dotfiles Test Infrastructure Specification

This document details the architecture, design principles, test tiers, assertion library, sandbox isolation mechanics, and execution instructions for the 4-tier End-to-End (E2E) automated testing harness.

______________________________________________________________________

## 1. Architectural Overview & Design Principles

The testing framework employs a 4-tier pyramid designed for sub-second developer feedback, deterministic isolated sandbox runs, and performance regression prevention across multi-platform environments (Linux and macOS).

```
                      +-----------------------------+
                      |   Tier 4: Benchmarking      |  < 2.0s SLA
                      +-----------------------------+
                   +-----------------------------------+
                   |    Tier 3: Integration & E2E      |  < 1.5s SLA
                   +-----------------------------------+
                +-----------------------------------------+
                |    Tier 2: Unit & Component Isolation   |  < 500ms SLA
                +-----------------------------------------+
             +-----------------------------------------------+
             |      Tier 1: Static & Syntax Validation       |  < 200ms SLA
             +-----------------------------------------------+
```

### Core Design Principles

1. **Deterministic Isolation**: Integration and performance tests execute within a dedicated temporary `$HOME` sandbox directory (`mktemp -d`), leaving the developer's workstation state untouched.
1. **Zero Facade Assertions**: Every test validates real functional logic and return values rather than mock signatures.
1. **Progressive Testability**: Tests adapt seamlessly to baseline configurations and progressive milestone enhancements (e.g., handling optional `custom.el` in Emacs, graceful offline fallback).
1. **Explicit SLAs**: Each tier enforces strict millisecond latency budgets to prevent developer workflow degradation.

______________________________________________________________________

## 2. Test Tier Specifications

### Tier 1: Static & Syntax Validation (`test/tier1_static.sh`)

- **SLA Budget**: \<200 ms
- **Scope**:
  - **Shell Syntax**: Exhaustive `bash -n` syntax validation across all repository shell scripts (`*.sh`, `*.symlink`, `*.bash`).
  - **Emacs Lisp Validation**: Batch S-expression syntax parsing (`emacs -Q --batch`) across all tracked `.el` files in `emacs/` (`load.d/*.el`, `config/*.el`, `emacs.symlink`, `early-init.el`), gracefully handling optional non-tracked files such as `custom.el`.
  - **SSH Client Routing**: Syntax parsing via `ssh -F ssh/config -G <host>` across multiple host patterns (`localhost`, `github.com`, `*.m3drano.ch`, `*.gce.compute.m3drano.ch`).
  - **Symlink Source Declarations**: Verification of all 16 canonical `*.symlink` files and directory structure integrity (e.g., `screen/` migration to `tmux/`).
  - **Executable Permissions**: Verification of `+x` permissions on all executable binaries and installation scripts (`bootstrap.sh`, `bin/*.sh`, `ssh/install.sh`, `os/*/*.sh`, `test/*.sh`).
  - **Security & Sanitization Lint**: Format-string security auditing (`printf` template verification) and `.gitignore` coverage for sensitive files (`custom.el`, `secrets.sh`).

### Tier 2: Unit & Component Isolation (`test/tier2_unit.sh`)

- **SLA Budget**: \<500 ms
- **Scope**:
  - **Path Manipulation Helpers (`profile.symlink`)**:
    - `path_contains`: Head match, middle match, tail match, substring rejection, empty PATH handling.
    - `path_prepend`: Prepending to empty PATH, prepending existing item (deduplication check), ignoring non-existent directories.
    - `path_append`: Appending to empty PATH, appending existing item, ignoring non-existent directories.
    - `dedup_path`: Deduplication while strictly preserving first-seen ordering, cleaning consecutive colons (`::`), handling single-entry and empty paths.
  - **Alias Cascades (`bash/bashrc.d.symlink/aliases.sh`)**:
    - `ls` / `tree` tool prioritization (`eza` -> `lsd` -> `ls -Fh --color=auto` / `ls -GFh`).
    - `cat` / `preview` tool prioritization (`bat` -> `batcat` -> system fallback).
    - Core interactive safety aliases (`cp -i`, `mv -i`, `mkdir -pv`, `g='git '`, `py='python3'`).
  - **Git Maintenance (`bin/git-clean.sh`)**:
    - `is_protected` logic: Verification of protected branch protection (`main`, `master`, `develop`, `dev`, `staging`, `release`, `production`, `trunk`), `CURRENT_BRANCH` protection, and deletion eligibility for feature branches (`feature/*`, `bugfix-*`).
    - CLI argument parser: Flags (`-h`, `--help`, `-n`, `--dry-run`, `-b`, `-g`, `-y`), mutual exclusion enforcement (`--branches-only` + `--gc-only`), unknown flag detection, and non-git repository rejection.
  - **Python Linter Cascade (`bin/epylint.sh`)**:
    - Priority cascading (`ruff check` -> `epylint` -> `pylint --single-file=y` -> warning fallback).
    - Argument forwarding and exit code handling.
  - **Bootstrap Symlink Helper (`link_file`)**:
    - Initial creation of symlinks for non-existent targets.
    - Idempotent no-op for pre-existing matching symlinks.
    - Automatic backup generation (`.bak`) when conflicting regular files exist.
    - Broken symlink replacement.

### Tier 3: Integration & Sandbox E2E (`test/tier3_integration.sh`)

- **SLA Budget**: \<1.5 s
- **Scope**:
  - **Isolated Bootstrap Execution**: Invocation of `./bootstrap.sh` inside pristine sandbox environment (`$SANDBOX_HOME`).
  - **Dotfile Target Mapping**: Verification that all 16 user dotfiles (`~/.bashrc`, `~/.profile`, `~/.bash_profile`, `~/.bashrc.d`, `~/.emacs`, `~/.emacs.d`, `~/.gitconfig`, `~/.gitignore_global`, `~/.tmux.conf`, `~/.vimrc`, `~/.dir_colors`, `~/.inputrc`, `~/.pdbrc`, `~/.pythonrc`, `~/.hushlogin`, `~/.latexmkrc`, `~/.bin`) resolve to canonical repository targets.
  - **Bootstrap Idempotency**: Re-execution of `./bootstrap.sh` produces zero exit code errors, generates zero new backup files, and preserves symlinks.
  - **Interactive Bash Initialization**: `HOME=$SANDBOX_HOME bash -i -c "exit 0"` loads cleanly, verifying environment readiness (`PS1`, aliases, `DOTFILES_PROFILE_LOADED`).
  - **Batch Emacs Initialization**: `HOME=$SANDBOX_HOME emacs -Q --batch -l early-init.el -l init.el` initializes and exits with code 0.
  - **Tmux Configuration**: Parsing and loading validation via `tmux -f ~/.tmux.conf start-server \; kill-server`.
  - **SSH Security & Permissions**: Strict enforcement of `0700` on `~/.ssh` and `0600` on `~/.ssh/config` and private keys (`github`, `google_compute_engine`), `0644` on public keys.

### Tier 4: Performance & Benchmarking (`test/tier4_perf.sh`)

- **SLA Budget**: \<2.0 s
- **Scope**:
  - **Interactive Bash Startup Latency**: 10-iteration benchmark measuring startup latency against the \<40ms SLA budget.
  - **Subshell Fork Audit**: Auditing `.bashrc` sourcing to ensure zero subshell PID drift and zero unnecessary forks during shell initialization.
  - **Batch Emacs Startup Latency**: Benchmark measuring Emacs batch initialization against the \<300ms SLA target.
  - **Harness Overhead Audit**: Overall validation overhead benchmarking.

______________________________________________________________________

## 3. Test Runner CLI Usage

The master runner `./test/test_dotfiles.sh` provides unified execution, selective tier targeting, and clean terminal reporting:

```bash
# Run complete test suite (all 4 tiers)
./test/test_dotfiles.sh

# Run specific tiers
./test/test_dotfiles.sh --tier-1   # Static & syntax validation
./test/test_dotfiles.sh --tier-2   # Unit tests & component isolation
./test/test_dotfiles.sh --tier-3   # Integration & sandbox E2E
./test/test_dotfiles.sh --tier-4   # Performance & benchmarking

# List available tiers and SLA targets
./test/test_dotfiles.sh --list

# View help and options
./test/test_dotfiles.sh --help
```

______________________________________________________________________

## 4. Test File Structure

```
test/
├── test_dotfiles.sh       # Unified master test runner CLI
├── test_helpers.sh        # Shared assertion library, timers, sandbox utilities
├── tier1_static.sh        # Tier 1: Static & syntax validation (<200ms)
├── tier2_unit.sh          # Tier 2: Unit & component isolation (<500ms)
├── tier3_integration.sh   # Tier 3: Integration & sandbox E2E (<1.5s)
└── tier4_perf.sh          # Tier 4: Performance & benchmarking (<2.0s)
```
