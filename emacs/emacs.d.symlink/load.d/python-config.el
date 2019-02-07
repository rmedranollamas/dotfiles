;;; python-config.el --- python-mode config.
;; -*- mode: Emacs-Lisp -*-

;; Enable pipenv.
(require 'pipenv)
(add-hook 'python-mode-hook #'pipenv-mode)

;; Jedi for Python.
(require 'company)
(require 'company-jedi)
(add-hook 'python-mode-hook #'jedi:setup)
(setq jedi:environment-virtualenv
      (append python-environment-virtualenv
              '("--python" "python3")))
(setq jedi:complete-on-dot t)
(add-to-list 'company-backends 'company-jedi)
