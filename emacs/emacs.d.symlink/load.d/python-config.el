;;; python-config.el --- python-mode config.
;; -*- mode: Emacs-Lisp -*-

(require 'flymake)

;; Load the virtualenvs.
(require 'virtualenvwrapper)
(venv-initialize-interactive-shells)
(setq venv-location "~/Code/.virtualenvs")

(defvar python-pylint nil "Path to epylint")
(setq python-pylint "~/.bin/epylint.sh")
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
(add-hook 'python-mode-hook 'flymake-mode)

;; Jedi for Python.
(add-hook 'python-mode-hook 'jedi:setup)
(defvar jedi:complete-on-dot nil "tell jedi to complete on dot")
(setq jedi:complete-on-dot t)

;; Activate minor whitespace mode when in python mode.
(add-hook 'python-mode-hook 'whitespace-mode)
