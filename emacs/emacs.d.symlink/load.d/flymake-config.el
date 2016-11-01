;;; flymake-config.el --- Configs for Flycheck et al.
;; -*- mode: Emacs-Lisp -*-

;; Flycheck config.
(add-hook 'after-init-hook #'global-flycheck-mode)

;; Also enable auto-complete.
(require 'auto-complete)
(ac-config-default)
(global-auto-complete-mode t)
