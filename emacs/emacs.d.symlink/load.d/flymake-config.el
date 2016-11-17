;;; flymake-config.el --- Configs for Flycheck et al.
;; -*- mode: Emacs-Lisp -*-

;; Flycheck config.
(add-hook 'after-init-hook #'global-flycheck-mode)
(global-flycheck-mode t)
(with-eval-after-load 'flycheck
  (flycheck-pos-tip-mode))

;; Also enable auto-complete.
(require 'auto-complete)
(ac-config-default)
(global-auto-complete-mode t)

;; codesearch stuff.
(require 'codesearch)
