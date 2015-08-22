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
