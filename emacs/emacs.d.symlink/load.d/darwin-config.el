;; -*- mode: Lisp -*-
;; OS X config

(if (string-equal system-type "darwin")
    ;; Use Spotlight for search.
    (defvar locate-command "mdfind")
)
