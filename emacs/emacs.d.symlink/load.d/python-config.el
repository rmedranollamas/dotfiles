;;; python-config.el --- python-mode config.
;; -*- mode: Emacs-Lisp -*-

;; Load the virtualenvs.
(require 'virtualenvwrapper)
(venv-initialize-interactive-shells)
(setq venv-location "~/Code/.virtualenvs")

;; Jedi for Python.
(add-hook 'python-mode-hook 'jedi:setup)
(defvar jedi:complete-on-dot nil "tell jedi to complete on dot")
(setq jedi:complete-on-dot t)
(require 'company)
(add-to-list 'company-backends 'company-jedi)

;; Activate minor whitespace mode when in python mode.
(add-hook 'python-mode-hook 'whitespace-mode)
