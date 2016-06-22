;;; 0package-config.el --- Marmelade and other repositories config.
;; -*- mode: Emacs-Lisp -*-

(require 'package)

;; Packages to be installed.
(setq package-list '(ac-math
                     auctex
                     auctex-latexmk
                     auto-complete
                     auto-complete-auctex
                     color-theme-solarized
                     diff-hl
                     flymake-go
                     go-mode
                     jedi
                     load-dir
                     linum
                     rfringe
                     virtualenvwrapper))

(add-to-list 'package-archives
             '("marmalade" .
               "https://marmalade-repo.org/packages/") t)

(add-to-list 'package-archives
             '("melpa" .
               "https://melpa.org/packages/") t)

(package-initialize)

;; If the repo archives are not downloaded, get them.
(unless package-archive-contents
  (package-refresh-contents))

;; Download the packages listed on top.
(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))
