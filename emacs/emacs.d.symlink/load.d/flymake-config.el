;;; flymake-config.el --- Configs for Flycheck et al.
;; -*- mode: Emacs-Lisp -*-

;; Flycheck config.
(add-hook 'after-init-hook 'global-flycheck-mode)
(global-flycheck-mode t)
(with-eval-after-load 'flycheck (flycheck-pos-tip-mode))
(setq flycheck-python-pylint-executable "python3")

;; company-mode.
(require 'company)
(global-company-mode 1)
(add-hook 'after-init-hook 'global-company-mode)
(global-set-key (kbd "M-/") 'company-manual-begin)
