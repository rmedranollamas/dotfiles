;;; git-config.el --- Configs for Git and other VCS.
;; -*- mode: Emacs-Lisp -*-

(cond (window-system
       (progn
         (require 'git-gutter-fringe)
         (setq git-gutter-fr:side 'right-fringe)
         (set-face-foreground 'git-gutter-fr:modified "yellow")
         (set-face-foreground 'git-gutter-fr:added "green")
         (set-face-foreground 'git-gutter-fr:deleted "red"))))
