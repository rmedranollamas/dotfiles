;;; darwin-config.el --- OS X config.
;; -*- mode: Emacs-Lisp -*-

(if (eq system-type 'darwin)
    (progn
      (when (memq window-system '(mac ns x))
        (exec-path-from-shell-initialize))
      ;; Use Spotlight for search files.
      (defvar locate-command "mdfind"))
)
