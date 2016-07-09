;;; darwin-config.el --- OS X config.
;; -*- mode: Emacs-Lisp -*-

(if (eq system-type 'darwin)
    (when (memq window-system '(mac ns))
      (exec-path-from-shell-initialize))
    ;; Use Spotlight for search files.
    (defvar locate-command "mdfind")
)
