;;; flymake-config.el --- Configs for Flymake et al.
;; -*- mode: Emacs-Lisp -*-

;; Flymake temp files not inplace.
(setq temporary-file-directory "~/.emacs.d/tmp/")

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
