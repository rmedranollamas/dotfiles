;;; early-init.el --- Early initialization configuration. -*- lexical-binding: t; -*-

;; Set high GC threshold during init.
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Defer file-name-handler-alist during init.
(defvar default-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

;; Restore GC threshold and file-name handlers after startup.
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold 800000 ; 800KB default
                  gc-cons-percentage 0.1
                  file-name-handler-alist default-file-name-handler-alist)))

;; Prefer loading newer compiled files.
(setq load-prefer-newer t)

;; Disable package initialization before loading init file.
(setq package-enable-at-startup nil)

;; Disable UI frame clutter before frame is drawn to avoid redraw flashing.
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)

;; Inhibit startup messages and splash screens.
(setq inhibit-startup-screen t
      inhibit-startup-echo-area-message user-login-name
      inhibit-splash-screen t
      initial-scratch-message "")

;; Silence native compilation warnings/errors if available.
(when (boundp 'native-comp-async-report-warnings-errors)
  (setq native-comp-async-report-warnings-errors 'silent))

(provide 'early-init)
;;; early-init.el ends here
