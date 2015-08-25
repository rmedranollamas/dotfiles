;; -*- mode: Lisp -*-
;; python-mode config

(require 'go-mode-autoloads)

;; Load flymake-go when using go-mode.
(eval-after-load "go-mode"
  '(require 'flymake-go))

;; Do not show the tabs as tabs, which is horrendous.
(add-hook 'go-mode-hook (lambda () (setq tab-width 2)))

;; Do gofmt on save.
(add-hook 'before-save-hook #'gofmt-before-save)