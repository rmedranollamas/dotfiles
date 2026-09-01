# Dotfiles (2026 Modern Edition)

A high-performance, modular, cross-platform configuration suite for Linux and macOS (Darwin), engineered for modern terminal workflows, hardened security, and lightning-fast execution.

______________________________________________________________________

## Key Highlights & Architecture

### 1. Tmux TrueColor & Modern Multiplexing

- **Full 24-bit TrueColor Support**: Configured for `tmux-256color` with terminal capability overrides (`Tc` and `RGB`) for accurate color reproduction across modern terminal emulators.
- **Ergonomic Bindings & Navigation**: Streamlined pane splits, vi-style navigation, automated window renumbering, and clean status bar integration.
- **Directory Structure**: Dedicated `tmux/` topical directory hosting `tmux.conf.symlink` -> `~/.tmux.conf`.

### 2. Bash 5 Zero-Fork Caching & Modern Toolchain

- **Zero-Fork Prompt Execution**: Refactored prompt handling in `prompt.sh` utilizing `_run_precmd_functions` and `declare -F` to render dynamic Git prompt state with 0 subshell forks.
- **Dynamic Lazy Completion**: Sourced on-demand using `complete -D` to eliminate shell startup overhead.
- **Dynamic CLI Tooling**: Automated aliases for modern Rust CLI replacements (`eza`/`lsd` for `ls`/`tree`, `bat`/`batcat` for `cat`/`preview`) with graceful fallbacks.
- **Advanced Shell Options**: Enabled `globstar` for recursive pattern matching, automatic window size adjustments (`checkwinsize`), and hardened grep defaults.

### 3. Emacs 29/30 Eglot, Tree-sitter & Built-in use-package

- **Early-Init GC Acceleration**: Configured `early-init.el` to boost `gc-cons-threshold` during startup to `most-positive-fixnum` (restored to 800kB on `emacs-startup-hook`) and disable `file-name-handler-alist`, achieving ~12x faster startup (~150ms).
- **Native Language Server Protocol (Eglot)**: Zero-dependency LSP client configured for Python, C/C++, Bash, JSON, YAML, and TOML.
- **Tree-sitter Grammar Integration**: Dynamic `major-mode-remap-alist` remappings activate `*-ts-mode` variants (`python-ts-mode`, `bash-ts-mode`, `json-ts-mode`, `yaml-ts-mode`, `c-ts-mode`, `toml-ts-mode`).
- **Modern Python Tooling**: Integrated Ruff linter/formatter with Pyvenv virtualenv management and multi-tier linter fallbacks.

### 4. SSH Physical Isolation & Hardened Defaults

- **Identity Isolation**: Dedicated Ed25519 cryptographic keys partitioned per infrastructure role:
  - `~/.ssh/github` for GitHub and Git hosting services.
  - `~/.ssh/google_compute_engine` for Google Cloud Platform / GCE hosts.
  - Domain-specific host mappings for personal infrastructure (`*.m3drano.ch`).
- **Hardened Global Policies**: Agent forwarding and X11 forwarding disabled by default (`ForwardAgent no`, `ForwardX11 no`), `IdentitiesOnly yes`, strict host-key verification, socket multiplexing (`ControlMaster auto`, `ControlPersist 600`), and enforced `0700`/`0600` directory and file permissions.

### 5. Multi-Tier Automated Test Suite & CI

- **4-Tier E2E Test Framework**: Built-in test runner at `test/test_dotfiles.sh` providing modular testing across:
  - **Tier 1 (Static & Syntax)**: `bash -n`, Emacs Lisp sexp validation, SSH syntax (`ssh -G`), Tmux config parsing, and Symlink mapping.
  - **Tier 2 (Unit & Isolation)**: Path helper algorithms, alias cascades, `git-clean.sh` branch safety logic, and `link_file` idempotency.
  - **Tier 3 (Integration & Sandbox E2E)**: Pristine bootstrap in isolated sandbox `$HOME`, idempotent consecutive runs, and permission audits.
  - **Tier 4 (Performance & Benchmarks)**: Interactive Bash startup latency (\<40ms SLA) and Emacs batch startup (\<300ms SLA).
- **Adversarial Stress Suite (Tier 5)**: Edge-case fuzzing and stress testing in `test/tier5_adversarial.sh`.
- **GitHub Actions CI Matrix**: Automated continuous integration on Linux and macOS with Dependabot maintenance.

______________________________________________________________________

## Repository Organization

The repository follows a topical modular pattern:

```text
dotfiles/
├── .github/                    # Continuous Integration & Automation
│   ├── workflows/ci.yml        # GitHub Actions matrix CI (Linux & macOS)
│   └── dependabot.yml          # Automated Action dependency updates
├── bash/                       # Bash configuration, aliases, completions
│   ├── bashrc.d.symlink/       # Modular shell scripts (aliases, completion, prompt, etc.)
│   ├── bashrc.symlink          # Sourced by interactive shells (~/.bashrc)
│   ├── bash_profile.symlink    # Login shell entrypoint (~/.bash_profile)
│   ├── dir_colors.symlink      # LS_COLORS color database (~/.dir_colors)
│   └── inputrc.symlink         # Readline keybindings (~/.inputrc)
├── bin/                        # Custom developer executables prepended to PATH
│   ├── epylint.sh              # Python linting wrapper (Ruff -> epylint -> pylint)
│   └── git-clean.sh            # Safe Git branch cleaner
├── emacs/                      # Emacs 29/30 configuration
│   ├── emacs.d.symlink/        # Modular Emacs configuration directory (~/.emacs.d)
│   │   ├── early-init.el       # Startup GC & frame accelerator
│   │   ├── config/             # Package and environment loaders
│   │   └── load.d/             # Modular topic configurations
│   └── emacs.symlink           # Early init / loader (~/.emacs)
├── git/                        # Git global configuration and ignore lists
│   ├── gitconfig.symlink       # Global Git configuration (~/.gitconfig)
│   └── gitignore_global.symlink# Global ignore patterns (~/.gitignore_global)
├── misc/                       # Miscellaneous application settings
│   ├── hushlogin.symlink       # Suppress login banner (~/.hushlogin)
│   └── latexmkrc.symlink       # Cross-platform LaTeXmk build rules (~/.latexmkrc)
├── os/                         # OS-specific bootstrap routines
│   ├── Darwin/                 # macOS defaults and packages
│   └── Linux/                  # Linux package and system configuration
├── python/                     # Python environment settings
│   ├── pdbrc.symlink           # PDB debugger enhancements (~/.pdbrc)
│   └── pythonrc.symlink        # Interactive Python shell configuration (~/.pythonrc)
├── ssh/                        # Hardened SSH configurations and key generators
│   ├── config                  # Master SSH client configuration
│   └── install.sh              # Automated keypair initialization
├── test/                       # Multi-Tier Automated Test Framework
│   ├── test_dotfiles.sh        # Unified master test runner CLI
│   ├── test_helpers.sh         # Shared assertions, timers, and sandboxes
│   ├── tier1_static.sh         # Tier 1: Static & syntax validation (<200ms)
│   ├── tier2_unit.sh           # Tier 2: Unit & component isolation (<500ms)
│   ├── tier3_integration.sh    # Tier 3: Integration & sandbox E2E (<1.5s)
│   ├── tier4_perf.sh           # Tier 4: Performance & benchmarking (<2.0s)
│   └── tier5_adversarial.sh    # Tier 5: Adversarial edge cases & stress tests
├── tmux/                       # Tmux TrueColor configuration
│   └── tmux.conf.symlink       # Terminal multiplexer settings (~/.tmux.conf)
├── vi/                         # Vim fallbacks
│   └── vimrc.symlink           # Clean Vim fallback configuration (~/.vimrc)
├── PROJECT.md                  # System architecture & interface contracts
├── TEST_INFRA.md               # Test framework specification & SLAs
└── bootstrap.sh                # Idempotent installation script
```

______________________________________________________________________

## Installation & Testing

### Installation

To bootstrap the configurations into your home directory:

```bash
./bootstrap.sh
```

`bootstrap.sh` performs the following steps:

1. Hardens `~/.ssh` and symlinks `ssh/config`.
1. Runs OS-specific initialization from `os/$(uname -s)/install.sh`.
1. Symlinks `bin/` to `~/.bin` and links all `*.symlink` files and directories to `~/.<name>`.
1. Executes topical `install.sh` scripts across all modules.

### Running Tests

Validate syntax, unit behavior, sandbox integration, and startup performance:

```bash
# Run all 4 test tiers
./test/test_dotfiles.sh

# Run specific test tiers
./test/test_dotfiles.sh --tier-1    # Static & syntax validation
./test/test_dotfiles.sh --tier-2    # Unit tests & component isolation
./test/test_dotfiles.sh --tier-3    # Integration & sandbox E2E
./test/test_dotfiles.sh --tier-4    # Performance & benchmarking

# List available tiers and SLA targets
./test/test_dotfiles.sh --list

# Run adversarial stress suite
./test/tier5_adversarial.sh
```
