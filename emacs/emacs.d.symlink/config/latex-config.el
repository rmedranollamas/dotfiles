;; -*- mode: Emacs-Lisp -*-

;; Set the path for TeXLive
(setq exec-path (append exec-path '("/usr/texbin")))
(setenv "PATH" (concat (getenv "PATH") ":/usr/texbin"))
(setq exec-path (append exec-path '("/usr/local/bin")))
(setenv "PATH" (concat (getenv "PATH") ":/usr/local/bin"))

;; Always use PDF mode.
(setq TeX-PDF-mode t)

;; Use flymake with LaTeX.
(add-hook 'LaTeX-mode-hook 'flymake-mode)

;; Enable flyspell automatically when loading a TeX file.
(add-hook 'LaTeX-mode-hook 'flyspell-mode)
(setq ispell-extra-args '("--sug-mode=fast"))

;; For LaTeX, let's use newer options.
(when (load "flymake" t)
  (defun flymake-get-tex-args (file-name)
    (list "/usr/texbin/pdflatex" (list "-file-line-error"
                                       "-draftmode"
                                       "-interaction=nonstopmode" file-name))))

;; Autocomplete with AuCTeX.
(require 'auto-complete-auctex)
