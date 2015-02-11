;; -*- mode: Emacs-Lisp -*-

;; Always use PDF mode.
(setq TeX-PDF-mode t)

;; Use flymake with LaTeX.
(add-hook 'LaTeX-mode-hook 'flymake-mode)

;; For LaTeX, let's use newer options.
(when (load "flymake" t)
  (defun flymake-get-tex-args (file-name)
    (list "pdflatex" (list "-file-line-error"
                           "-draftmode"
                           "-interaction=nonstopmode" file-name))))
