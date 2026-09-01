;;; darwin-config.el --- OS X configuration. -*- lexical-binding: t; -*-

(defvar locate-command)
(defvar exec-path-from-shell-arguments)
(defvar exec-path-from-shell-variables)
(declare-function exec-path-from-shell-initialize "exec-path-from-shell")

(when (eq system-type 'darwin)
  ;; Import environment variables from shell in GUI mode.
  (when (memq window-system '(mac ns x))
    (use-package exec-path-from-shell
      :ensure t
      :config
      (setq exec-path-from-shell-arguments '("-l"))
      (add-to-list 'exec-path-from-shell-variables "LC_ALL")
      (exec-path-from-shell-initialize)))

  ;; Use Spotlight for searching files.
  (setq locate-command "mdfind")

  ;; Hyper key shortcuts for macOS.
  (global-set-key [(hyper a)] 'mark-whole-buffer)
  (global-set-key [(hyper v)] 'yank)
  (global-set-key [(hyper c)] 'kill-ring-save)
  (global-set-key [(hyper s)] 'save-buffer)
  (global-set-key [(hyper l)] 'goto-line)
  (global-set-key [(hyper w)]
                  (lambda () (interactive) (delete-window)))
  (global-set-key [(hyper z)] 'undo))

(provide 'darwin-config)
;;; darwin-config.el ends here
