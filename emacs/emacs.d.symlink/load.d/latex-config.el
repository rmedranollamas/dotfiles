;;; latex-config.el --- Configs for AuCTeX.
;; -*- mode: Emacs-Lisp -*-

;; Basics.
(require 'tex)
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)
(require 'latex)
(add-hook 'LaTeX-mode-hook #'visual-line-mode)
(add-hook 'LaTeX-mode-hook #'LaTeX-math-mode)

;; Use latexmk.
(require 'auctex-latexmk)
(auctex-latexmk-setup)
(setq auctex-latexmk-inherit-TeX-PDF-mode t)
(setq TeX-command-default "LatexMk")

;; Always use PDF mode.
(setq TeX-PDF-mode t)

;; Enable flyspell automatically when loading a TeX file.
(add-hook 'LaTeX-mode-hook 'turn-on-flyspell)
(defvar ispell-extra-args nil "extra args for ispell")
(setq ispell-extra-args '("--sug-mode=fast"))

;; SyncTeX
(setq TeX-view-program-selection '((output-pdf "Skim")))
(add-hook 'LaTeX-mode-hook 'TeX-source-correlate-mode)
(setq TeX-source-correlate-method 'synctex)

(add-hook 'LaTeX-mode-hook
          (lambda()
            (add-to-list 'TeX-expand-list
                         '("%q" skim-make-url))))

(defun skim-make-url () (concat
                         (TeX-current-line)
                         " "
                         (expand-file-name (funcall file (TeX-output-extension) t)
                                           (file-name-directory (TeX-master-file)))
                         " "
                         (buffer-file-name)
                         ))

(setq TeX-view-program-list
      '(("Skim" "/Applications/Skim.app/Contents/SharedSupport/displayline %q")))
