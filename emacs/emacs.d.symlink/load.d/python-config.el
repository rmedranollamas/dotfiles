;;; python-config.el --- python-mode config.
;; -*- mode: Emacs-Lisp -*-

;; Enable pipenv.
(add-hook 'python-mode-hook #'pipenv-mode)

;; Jedi for Python.
(add-hook 'python-mode-hook 'jedi:setup)
(defvar jedi:complete-on-dot nil "tell jedi to complete on dot")
(setq jedi:complete-on-dot t)
(require 'company)
(add-to-list 'company-backends 'company-jedi)
