;; -*- mode: Emacs-Lisp -*-

;; Nuke trailing whitespaces at save.
(add-hook 'write-file-hooks 'delete-trailing-whitespace)

;; Do not generate backup files.
(setq make-backup-files nil)
