;;; 0package-config.el --- Package manager and core packages config. -*- lexical-binding: t; -*-

(require 'package)
(setq package-user-dir (expand-file-name "elpa" user-emacs-directory))
(setq package-archives '(("gnu"   . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))
(package-initialize)

;; Bootstrap use-package cleanly without periodic synchronous network calls.
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Project management.
(use-package projectile
  :ensure t
  :defer t
  :hook (after-init . projectile-mode)
  :bind (:map projectile-mode-map
              ("C-c p" . projectile-command-map))
  :config
  (setq projectile-enable-caching t))

(provide '0package-config)
;;; 0package-config.el ends here
