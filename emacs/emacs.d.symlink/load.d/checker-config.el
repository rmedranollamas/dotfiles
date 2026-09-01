;;; checker-config.el --- Syntax checking. -*- lexical-binding: t; -*-

(declare-function flycheck-mode "flycheck" (&optional arg))

;; Flycheck config deferred on prog-mode (excluding lisp-interaction-mode).
(use-package flycheck
  :ensure t
  :defer t
  :hook (prog-mode . (lambda ()
                       (unless (derived-mode-p 'lisp-interaction-mode)
                         (flycheck-mode 1))))
  :config
  (use-package flycheck-color-mode-line
    :ensure t
    :hook (flycheck-mode . flycheck-color-mode-line-mode))
  (use-package flycheck-pos-tip
    :ensure t
    :hook (flycheck-mode . flycheck-pos-tip-mode)))

(provide 'checker-config)
;;; checker-config.el ends here
