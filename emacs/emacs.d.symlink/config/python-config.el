;; -*- mode: Lisp -*-
;; python-mode config

;; Activate minor whitespace mode when in python mode.
(add-hook 'python-mode-hook 'whitespace-mode)

;; Add a shortcut for indenting and "out"denting.
(global-set-key (kbd "C-.") 'python-indent-shift-right)
(global-set-key (kbd "C-,") 'python-indent-shift-left)

;; Configure flymake for Python
(defvar python-pylint nil "Path to epylint")
(setq python-pylint "/usr/local/bin/epylint")
(when (load "flymake" t)
  (defun flymake-pylint-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
           (local-file (file-relative-name
                        temp-file
                        (file-name-directory buffer-file-name))))
      (list (expand-file-name python-pylint "") (list local-file))))
  (add-to-list 'flymake-allowed-file-name-masks
               '("\\.py\\'" flymake-pylint-init)))

;; Django modes.
(add-to-list 'auto-mode-alist '("\\.djhtml$" . django-html-mode))

;; Load the virtualenvs.
(require 'virtualenvwrapper)
; (venv-initialize-interactive-shells)
; (venv-initialize-eshell)
(setq venv-location "~/.virtualenvs")
