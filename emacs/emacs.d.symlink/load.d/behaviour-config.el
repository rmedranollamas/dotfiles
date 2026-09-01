;;; behaviour-config.el --- Behavioural setup and configs. -*- lexical-binding: t; -*-

;; Nuke trailing whitespaces before saving files.
(add-hook 'before-save-hook #'delete-trailing-whitespace)

;; Backups into a centralized directory.
(setq backup-directory-alist '(("." . "~/.saves/"))
      backup-by-copying t
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)

;; Do not ring bells.
(setq visible-bell t
      ring-bell-function 'ignore)

;; IDO configuration deferred to after-init.
(require 'ido)
(setq ido-enable-flex-matching t
      ido-everywhere t)
(add-hook 'after-init-hook #'ido-mode)

;; Auto revert mode.
(require 'autorevert)
(global-auto-revert-mode 1)
(setq auto-revert-check-vc-info t)

;; Re-enable some functions.
(put 'downcase-region 'disabled nil)
(global-eldoc-mode -1)
(global-hl-line-mode 1)

(provide 'behaviour-config)
;;; behaviour-config.el ends here
