;;; 0package-config.el --- Marmelade and other repositories config.
;; -*- mode: Emacs-Lisp -*-

(require 'package)

(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")
(when (< emacs-major-version 24)
  (add-to-list 'package-archives
	       '("gnu" . "https://elpa.gnu.org/packages/") t))
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)

(package-initialize)

;; Packages to be installed.
(setq package-selected-packages
      '(auctex
        auctex-latexmk
        company
        company-jedi
        exec-path-from-shell
        fill-column-indicator
        flycheck
        flycheck-color-mode-line
        flycheck-pos-tip
        load-dir
        pipenv
        projectile
        solarized-theme
        use-package))

(defun install-packages ()
  "Install all required packages."
  (interactive)
  (unless package-archive-contents
    (package-refresh-contents))
  (dolist (package package-selected-packages)
    (unless (package-installed-p package)
      (package-install package))))

(setq abbrev-file-name "~/.emacs.d/abbrev_defs")
(quietly-read-abbrev-file "~/.emacs.d/abbrev_defs")
