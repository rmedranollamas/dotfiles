;;; darwin-config.el --- OS X config.
;; -*- mode: Emacs-Lisp -*-

(if (string-equal system-type "darwin")
    (setq exec-path (append exec-path '("/usr/local/bin")))
    (setenv "PATH" (concat (getenv "PATH") ":/usr/local/bin"))
    ;; Use Spotlight for search files.
    (defvar locate-command "mdfind")
)
