;;; flymake-config.el --- Configs for Flycheck et al.
;; -*- mode: Emacs-Lisp -*-

;; Flycheck config.
(add-hook 'after-init-hook #'global-flycheck-mode)
(global-flycheck-mode t)
(with-eval-after-load 'flycheck
  (flycheck-pos-tip-mode))


;; codesearch stuff.
(require 'codesearch)

;; company-mode.
(require 'company)
(global-company-mode 1)
(add-hook 'after-init-hook 'global-company-mode)
(global-set-key (kbd "M-/") 'company-manual-begin)

;; YouCompleteMe configuration.
(require 'ycmd)
(add-hook 'after-init-hook 'global-ycmd-mode)
(require 'company-ycmd)
(company-ycmd-setup)
