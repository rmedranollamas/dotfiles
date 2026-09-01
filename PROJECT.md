# Project: Dotfiles Modernization and Optimization

## Architecture

The repository manages personal dotfiles across shell, editor, multiplexer, version control, security, and OS environments.

- **Load Order & Data Flow**:
  - `bootstrap.sh`: Symlinks all `*.symlink` files into `$HOME/.<name>` and establishes directory permissions (`0700` for `~/.ssh`, `~/.saves`, `~/.emacs.d/auto-saves`).
  - Shell Environment: Login shells execute `~/.bash_profile` -> `~/.profile` -> `~/.bashrc`. Interactive shells execute `~/.bashrc` -> `platform/${UNAME}.sh` -> `bashrc.d/*.sh` alphabetically (`aliases`, `bash`, `colors`, `completion`, `history`, `less`, `prompt`, `python`).
  - Emacs: Bootstrapped via `early-init.el` (GC tuning, UI inhibition) -> `init.el` / `emacs.symlink` -> `load.d/*.el` alphabetically.
  - SSH: Hardened `ssh/config` enforces key isolation, `IdentitiesOnly`, `ForwardAgent no`, ed25519 keys (`0600`/`0700`).
  - Git: `gitconfig.symlink` configures atomic signed pushes, zdiff3 conflicts, and histogram diffs.

## Feature Inventory

- F1: Emacs Lisp Test Suite Pass (`test/test_dotfiles.sh` handles optional `custom.el`) | M1 | Done
- F2: Script Sanitization & Format String Fix (`bootstrap.sh` `printf` format strings and variable quoting) | M1 | Done
- F3: SSH Directory Permissions and Key Security Enforcements (`0700`/`0600` permissions and isolation) | M1 | Done
- F4: Emacs 29+ Built-in `use-package` & Zero-Network Offline Startup (`0package-config.el` `require 'use-package'`) | M2 | Done
- F5: Emacs Early-Init GC & Native-Comp Optimization (`early-init.el` GC threshold restoration) | M2 | Done
- F6: Emacs Security Load Ordering & Theme Safety (`security-config.el` evaluation before package setup, safe theme loading) | M2 | Done
- F7: Emacs Built-ins Modernization (`eglot`, `treesit`, `project.el` `:ensure nil` configurations) | M2 | Done
- F8: Bash Lazy Completion Loader (`completion.sh` `complete -D` lazy-loading system completion) | M3 | Done
- F9: Bash Zero-Fork Prompt & Built-in Optimization (`prompt.sh` zero-fork `declare -F` and `PROMPT_COMMAND` git status) | M3 | Done
- F10: Bash ANSI-C Quoting for `less.sh` (`less.sh` zero-fork `$'\e[...'` escaping) | M3 | Done
- F11: Linuxbrew Mtime Caching in `platform/Linux.sh` (zero-fork shellenv caching parity with `Darwin.sh`) | M3 | Done
- F12: Zero-Fork Extglob Parameter Expansion in `bin/git-clean.sh` (pure bash branch trimming) | M3 | Done
- F13: Tmux TrueColor, Status Line, and System Clipboard Cascade Maintenance | M3 | Done
- F14: Git Config Cross-Platform Compatibility and Key Signing Integrity | M3 | Done
- F15: E2E 4-Tier Test Suite Infrastructure (Static, Unit, Integration, Benchmarking) | M0_TEST | Done
- F16: Final Milestone 100% E2E Pass & Tier 5 Adversarial Coverage Hardening | M4 | Done

## Milestones

- M0_TEST: E2E Testing Track Infrastructure & Test Tiers (Tiers 1-4 test runner and assertions) | Dependencies: none | Status: DONE
- M1: Baseline Structural Integrity, Security Remediation & Script Sanitization | Dependencies: none | Status: DONE
- M2: Emacs 29+ Modernization, Startup Acceleration & Package Optimization | Dependencies: M1 | Status: DONE
- M3: Bash Zero-Fork Caching, Lazy Completion & Shell/Tmux/Git Optimization | Dependencies: M1 | Status: DONE
- M4: Final Integration, 100% E2E Verification & Adversarial Hardening | Dependencies: M0_TEST, M2, M3 | Status: DONE

## Interface Contracts

- Shell Environment -> Prompt: `_run_precmd_functions` sets `__git_prompt_str` in parent shell; `PS1` consumes `${__git_prompt_str}` with zero subshell forks.
- Shell Environment -> Lazy Completion: `complete -D -F _lazy_bash_completion` intercepts first completion request, sources system `bash_completion`, and re-triggers completion.
- Emacs -> Init sequence: `early-init.el` raises `gc-cons-threshold` to `most-positive-fixnum` and restores to `800000` via `emacs-startup-hook`.
- Bootstrap -> Permissions: Enforces `chmod 700 ~/.ssh ~/.saves ~/.emacs.d/auto-saves` and `chmod 600 ~/.ssh/config`.

## Code Layout

- `emacs/`: Owned exclusively by Milestone 2 Worker.
- `bash/`: Owned exclusively by Milestone 3 Worker.
- `tmux/`, `python/`, `git/`, `ssh/`: Owned by Milestone 3 Worker.
- `bin/`, `bootstrap.sh`, `os/`: Owned by Milestone 1 Worker for sanitization; Milestone 3 for shell scripts.
- `test/`: Owned exclusively by E2E Testing Track Worker / Test Writer.
