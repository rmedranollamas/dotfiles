;; -*- mode: Lisp -*-
;; OS X config

(if (string-equal system-type "darwin")
    ;; Use Spotlight for search.
    (setq locate-command "mdfind")
)
