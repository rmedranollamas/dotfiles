;; -*- mode: Lisp -*-
;; python-mode config

;; Load the virtualenvs.
(require 'virtualenvwrapper)
(venv-initialize-interactive-shells)
(setq venv-location "/Users/m3drano/.virtualenvs")

(when (load "flymake" t)
  (defun flymake-pylint-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
           (local-file (file-relative-name
                        temp-file
                        (file-name-directory buffer-file-name))))
      (list (expand-file-name "/usr/local/bin/epylint" "") (list local-file))))
  (add-to-list 'flymake-allowed-file-name-masks
               '("\\.py\\'" flymake-pylint-init)))

;; Django modes.
(add-to-list 'auto-mode-alist '("\\.djhtml$" . django-html-mode))

;; Jedi for Python.
(add-hook 'python-mode-hook 'jedi:setup)
(setq jedi:complete-on-dot t)

;; Activate minor whitespace mode when in python mode.
(add-hook 'python-mode-hook 'whitespace-mode)
