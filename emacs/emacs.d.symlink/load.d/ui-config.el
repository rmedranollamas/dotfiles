;;; ui-config.el --- General UI configurations.
;; -*- mode: Emacs-Lisp -*-

;; Custom configurations for the interface.
(blink-cursor-mode 0)
(line-number-mode t)
(column-number-mode t)
(show-paren-mode 1)
(menu-bar-mode 0)
(setq inhibit-splash-screen t)
(cua-mode t)
(defvar cua-auto-tabify-rectangles nil)
(transient-mark-mode 1)
(global-font-lock-mode 1)

;; Load Solarized theme.
(require 'solarized-theme)
(load-theme 'solarized-light t)

;; Indentation.
(setq-default tab-width 2)
(defvaralias 'c-basic-offset 'tab-width)
(defvaralias 'c-basic-indent 'tab-width)
(setq-default indent-tabs-mode nil)

;; Use Wind Move.
(global-set-key (kbd "C-x <up>") 'windmove-up)
(global-set-key (kbd "C-x <down>") 'windmove-down)
(global-set-key (kbd "C-x <right>") 'windmove-right)
(global-set-key (kbd "C-x <left>") 'windmove-left)

;; A handy shortcut for increasing buffer size in split mode.
(defun halve-other-window-height ()
  (interactive)
  (enlarge-window (/ (window-height (next-window)) 2)))
(global-set-key (kbd "C-c v") 'halve-other-window-height)

;; Show color sequences as colors.
(add-hook 'shell-mode-hook #'ansi-color-for-comint-mode-on)

;; Others
(setq initial-scratch-message "")
(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message user-login-name)

;; Show warnings for long lines.
(require 'fill-column-indicator)
(setq-default fill-column 80)

;; Options when using the window manager.
(setq frame-title-format
      '("Emacs - " (buffer-file-name "%f"
                                     (dired-directory dired-directory "%b"))))
(when (functionp 'scroll-bar-mode)
  (scroll-bar-mode 0))
(when (functionp 'tool-bar-mode)
  (tool-bar-mode 0))
(add-to-list 'default-frame-alist '(width  . 90))
(add-to-list 'default-frame-alist '(height . 70))
(add-to-list 'default-frame-alist '(font . "IBM Plex Mono 14"))

;; Improvements to X11 clipbard integration.
(setq mouse-drag-copy-region nil)
(setq select-enable-primary nil)
(setq select-enable-clipboard t)
(setq select-active-regions t)
