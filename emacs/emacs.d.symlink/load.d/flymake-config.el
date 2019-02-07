;;; flymake-config.el --- Configs for Flycheck et al.
;; -*- mode: Emacs-Lisp -*-

;; Flycheck config.
(require 'flycheck)
(require 'flycheck-color-mode-line)
(require 'flycheck-pos-tip)
(add-hook 'after-init-hook #'global-flycheck-mode)
(with-eval-after-load 'flycheck
  (add-hook 'flycheck-mode-hook #'flycheck-pos-tip-mode)
  (add-hook 'flycheck-mode-hook #'flycheck-color-mode-line-mode))
(global-flycheck-mode t)

;; company-mode.
(require 'company)
(global-company-mode 1)
(add-hook 'after-init-hook #'global-company-mode)
