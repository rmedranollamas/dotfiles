;;; flymake-config.el --- Configs for Flymake et al.
;; -*- mode: Emacs-Lisp -*-

(require 'flymake)

;; Flymake temp files not inplace.
(setq flymake-run-in-place nil)
(setq temporary-file-directory "~/.emacs.d/tmp/")

;; Let's run as much checks as we want to.
(setq flymake-max-parallel-syntax-checks nil)

;; I want to see all errors for the line.
(setq flymake-number-of-errors-to-display nil)

;; Show details of errors on the minubuffer.
(eval-after-load 'flymake '(require 'flymake-cursor))

;; Show errors on the right fringe.
(cond (window-system
       (progn
         (eval-after-load 'flymake '(require 'rfringe)))))

;; Also enable auto-complete.
(require 'auto-complete)
(ac-config-default)
(global-auto-complete-mode t)
