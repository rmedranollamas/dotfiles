;;; darwin-config.el --- OS X config.
;; -*- mode: Emacs-Lisp -*-

(if (string-equal system-type "darwin")
    ;; Use Spotlight for search files.
    (defvar locate-command "mdfind")
)
