;;; python-config.el --- python-mode config.
;; -*- mode: Emacs-Lisp -*-

;; Enable pyenv.
(pyenv-mode)
(require 'pyenv-mode-auto)

;; Jedi for Python.
(add-hook 'python-mode-hook 'jedi:setup)
(defvar jedi:complete-on-dot nil "tell jedi to complete on dot")
(setq jedi:complete-on-dot t)
(require 'company)
(add-to-list 'company-backends 'company-jedi)
