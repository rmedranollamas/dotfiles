;; -*- mode: Emacs-Lisp -*-

;; Enable Flymake by default.
(require 'flymake)
(flymake-mode 1)

;; Enable Flymake on every file load.
(add-hook 'find-file-hook 'flymake-find-file-hook)

;; Show details of errors on the minubuffer.
(eval-after-load 'flymake '(require 'flymake-cursor))

;; Show errors on the right fringe.
(eval-after-load 'flymake '(require 'rfringe))

;; Also enable auto-complete.
(require 'auto-complete)
(global-auto-complete-mode t)
