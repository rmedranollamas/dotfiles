;; -*- mode: Emacs-Lisp -*-
;; linum config

(require 'linum)

(global-linum-mode 1)

(setq linum-format "%4d ")

;; Warnings for too wide lines.
(add-hook 'c++-mode-hook
          '(lambda () (font-lock-set-up-width-warning 100)))
(add-hook 'java-mode-hook
          '(lambda () (font-lock-set-up-width-warning 100)))
(add-hook 'python-mode-hook
          '(lambda () (font-lock-set-up-width-warning 90)))
