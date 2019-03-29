;;; behaviour-config.el --- Behavioural setup and configs.
;; -*- mode: Emacs-Lisp -*-

;; Nuke trailing whitespaces at save.
(add-hook 'write-file-hooks #'delete-trailing-whitespace)

;; Do not ask to follow a link to a version controlled file.
(setq vc-follow-symlinks t)

;; Backups into a separate directory
(add-to-list 'backup-directory-alist '("." . "~/.saves") :append)
(customize-set-variable 'backup-by-copying t)
(customize-set-variable 'delete-old-versions t)
(customize-set-variable 'kept-new-versions 6)
(customize-set-variable 'kept-old-versions 2)
(customize-set-variable 'version-control t)

;; Do not ring bells.
(setq visible-bell t)
(setq ring-bell-function 'ignore)

;; IDO.
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode 1)

;; Auto revert mode.
(global-auto-revert-mode)
(setq auto-revert-check-vc-info t)

;; Re-enable some functions.
(put 'downcase-region 'disabled nil)
(global-eldoc-mode -1)
(global-hl-line-mode 1)

;; Enable projectile
(projectile-mode +1)
