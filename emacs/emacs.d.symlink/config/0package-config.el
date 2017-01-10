;;; 0package-config.el --- Marmelade and other repositories config.
;; -*- mode: Emacs-Lisp -*-

(require 'package)

(when (< emacs-major-version 24)
  (add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/")))
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)

(package-initialize)

;; Packages to be installed.
(setq package-selected-packages
      '(auctex
        auctex-latexmk
        codesearch
        color-theme-solarized
        company
        company-jedi
        company-ycmd
        diff-hl
        exec-path-from-shell
        flycheck
        flycheck-pos-tip
        go-mode
        load-dir
        magit
        rfringe
        virtualenvwrapper
        ycmd))

(defun install-packages ()
  "Install all required packages."
  (interactive)
  (unless package-archive-contents
    (package-refresh-contents))
  (dolist (package package-selected-packages)
    (unless (package-installed-p package)
      (package-install package))))

(install-packages)
