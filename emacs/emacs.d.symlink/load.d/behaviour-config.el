;;; behaviour-config.el --- Behavioural setup and configs.
;; -*- mode: Emacs-Lisp -*-

;; Nuke trailing whitespaces at save.
(add-hook 'write-file-hooks 'delete-trailing-whitespace)

;; Do not ask to follow a link to a version controlled file.
(setq vc-follow-symlinks t)

;; Do not generate backup files.
(setq make-backup-files nil)

;; Do not ring bells.
(setq visible-bell t)
(setq ring-bell-function 'ignore)

;; IDO.
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode 1)
