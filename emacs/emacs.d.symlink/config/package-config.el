;; -*- mode: Lisp -*-
;; Marmelade and other repositories config.

(require 'package)

;; On Emacs older than 24.x there is no default repository.
(when (< emacs-major-version 24)
  (add-to-list 'package-archives
               '("gnu" .
                 "http://elpa.gnu.org/packages/") t))

(add-to-list 'package-archives
             '("melpa" .
               "http://melpa.milkbox.net/packages/") t)

(package-initialize)

;; If the repo archives are not downloaded, get them.
(when (not package-archive-contents)
  (package-refresh-contents))
