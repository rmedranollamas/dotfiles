;;; latex-config.el --- Configs for AuCTeX.
;; -*- mode: Emacs-Lisp -*-

;; Set the path for TeXLive
(setq exec-path (append exec-path '("/usr/texbin")))
(setenv "PATH" (concat (getenv "PATH") ":/usr/texbin"))
(setq exec-path (append exec-path '("/usr/local/bin")))
(setenv "PATH" (concat (getenv "PATH") ":/usr/local/bin"))

;; Use latexmk.
(require 'auctex-latexmk)
(auctex-latexmk-setup)
(setq auctex-latexmk-inherit-TeX-PDF-mode t)

;; Always use PDF mode.
(defvar TeX-PDF-mode nil "PDFmode for TeX")
(setq TeX-PDF-mode t)

;; Enable flyspell automatically when loading a TeX file.
(add-hook 'LaTeX-mode-hook 'flyspell-mode)
(defvar ispell-extra-args nil "extra args for ispell")
(setq ispell-extra-args '("--sug-mode=fast"))

;; We need to load the auto-complete before.
(require 'auto-complete)

;; Autocomplete with AuCTeX.
(require 'auto-complete-auctex)

;; Autocompletion of math symbols.
(require 'ac-math)
(add-to-list 'ac-modes 'latex-mode)
(defun ac-latex-mode-setup ()
  (setq ac-math-unicode-in-math-p t)
  (setq ac-sources
    (append
      '(ac-source-math-unicode ac-source-math-latex ac-source-latex-commands)
      ac-sources)))
(add-hook 'TeX-mode-hook 'ac-latex-mode-setup)
(ac-flyspell-workaround)
