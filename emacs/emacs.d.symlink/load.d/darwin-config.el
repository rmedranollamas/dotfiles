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
)
