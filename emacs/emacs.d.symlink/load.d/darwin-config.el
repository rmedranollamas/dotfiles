;;; darwin-config.el --- OS X config.
;; -*- mode: Emacs-Lisp -*-

(if (eq system-type 'darwin)
    (progn
      (when (memq window-system '(mac ns x))
        (require 'exec-path-from-shell)
        (setq exec-path-from-shell-arguments '("-l"))
        (add-to-list 'exec-path-from-shell-variables "LC_ALL")
        (exec-path-from-shell-initialize))
      ;; Use Spotlight for search files.
      (defvar locate-command "mdfind"))

  (global-set-key [(hyper a)] 'mark-whole-buffer)
  (global-set-key [(hyper v)] 'yank)
  (global-set-key [(hyper c)] 'kill-ring-save)
  (global-set-key [(hyper s)] 'save-buffer)
  (global-set-key [(hyper l)] 'goto-line)
  (global-set-key [(hyper w)]
                  (lambda () (interactive) (delete-window)))
  (global-set-key [(hyper z)] 'undo)
)
