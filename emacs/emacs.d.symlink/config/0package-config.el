;; -*- mode: Lisp -*-
;; Marmelade and other repositories config.

(require 'package)

;; Packages to be installed.
(setq package-list '(ac-math
                     auctex
                     auto-complete
                     auto-complete-auctex
                     color-theme-solarized
                     flymake-cursor
                     flymake-go
                     go-mode
                     load-dir
                     rfringe
                     virtualenvwrapper))

;; On Emacs older than 24.x there is no default repository.
(when (< emacs-major-version 24)
  (add-to-list 'package-archives
               '("gnu" .
                 "https://elpa.gnu.org/packages/") t))

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
