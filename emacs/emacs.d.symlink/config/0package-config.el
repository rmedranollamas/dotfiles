;;; 0package-config.el --- Package manager and core packages config. -*- lexical-binding: t; -*-

(require 'package)
(setq package-user-dir (expand-file-name "elpa" user-emacs-directory))
(setq package-archives '(("gnu"   . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))
(package-initialize)

;; In Emacs 29+, use-package is built into core.
(require 'use-package)
(require 'use-package-ensure)
(setq use-package-always-ensure t)

;; Read cached archive contents from disk if available to avoid unneeded network calls.
(unless package-archive-contents
  (package-read-all-archive-contents))

;; Clean offline / non-blocking package ensure handler.
(defvar dotfiles--package-refreshed nil)
(defun dotfiles-use-package-ensure (name args _state &optional _no-refresh)
  (dolist (ensure args)
    (let ((package (or (and (eq ensure t) (use-package-as-symbol name)) ensure)))
      (when package
        (when (consp package)
          (use-package-pin-package (car package) (cdr package))
          (setq package (car package)))
        (unless (package-installed-p package)
          (condition-case-unless-debug err
              (progn
                (unless (or package-archive-contents dotfiles--package-refreshed noninteractive)
                  (setq dotfiles--package-refreshed t)
                  (ignore-errors (package-refresh-contents)))
                (when (assoc package package-archive-contents)
                  (package-install package))
                t)
            (error
             (display-warning 'use-package
                              (format "Failed to install %s: %s"
                                      name (error-message-string err))
                              :warning))))))))
(setq use-package-ensure-function #'dotfiles-use-package-ensure)

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
