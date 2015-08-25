;; -*- mode: Emacs-Lisp -*-

;; Enable Flymake by default.
(require 'flymake)

;; Flymake temp files not inplace.
(setq temporary-file-directory "~/.emacs.d/tmp/")

;; Enable Flymake on every file load.
(add-hook 'find-file-hook 'flymake-find-file-hook)

;; Show details of errors on the minubuffer.
(eval-after-load 'flymake '(require 'flymake-cursor))

;; Show errors on the right fringe.
;(eval-after-load 'flymake '(require 'rfringe))

;; Also enable auto-complete.
(require 'auto-complete)
(ac-config-default)
(global-auto-complete-mode t)

(flymake-mode t)
