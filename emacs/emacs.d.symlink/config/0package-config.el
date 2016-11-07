;;; 0package-config.el --- Marmelade and other repositories config.
;; -*- mode: Emacs-Lisp -*-

(require 'package)

(when (< emacs-major-version 24)
  (add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/")))
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)

(package-initialize)

;; Packages to be installed.
(setq package-selected-packages
      '(ac-math
        auctex
        auctex-latexmk
        auto-complete
        auto-complete-auctex
        color-theme-solarized
        diff-hl
        exec-path-from-shell
        flycheck
        go-mode
        jedi
        load-dir
        linum
        rfringe
        virtualenvwrapper
        magit))

(defun install-packages ()
  "Install all required packages."
  (interactive)
  (unless package-archive-contents
    (package-refresh-contents))
  (dolist (package package-selected-packages)
    (unless (package-installed-p package)
      (package-install package))))

(install-packages)
