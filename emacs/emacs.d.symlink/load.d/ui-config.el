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
(require 'cl-lib)
(custom-set-variables
 '(solarized-termcolors 256)
 '(solarized-broken-srgb t)
 '(frame-background-mode 'light))
(load-theme 'solarized t)
(add-hook 'after-make-frame-functions
          (lambda (frame)
            (set-frame-parameter frame 'background-mode 'light)
            (set-terminal-parameter frame 'background-mode 'light)
            (enable-theme 'solarized)))

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
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;; Others
(setq initial-scratch-message "")
(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message user-login-name)

;; Show warnings for long lines.
(require 'whitespace)
(global-whitespace-mode t)
(setq whitespace-line-column 80
     whitespace-style '(face tabs trailing lines-tail))
(setq whitespace-global-modes '(not go-mode))

;; Formats for the warnings.
(set-face-attribute 'whitespace-line nil
                   :background "red1"
                   :foreground "yellow"
                   :weight 'bold)
(set-face-attribute 'whitespace-tab nil
                   :background "red1"
                   :foreground "yellow"
                   :weight 'bold)

;; Options when using the window manager.
(setq frame-title-format
      '("Emacs - " (buffer-file-name "%f"
                                     (dired-directory dired-directory "%b"))))
(when (functionp 'scroll-bar-mode)
  (scroll-bar-mode 0))
(when (functionp 'tool-bar-mode)
  (tool-bar-mode 0))
(add-to-list 'default-frame-alist '(width  . 90))
(add-to-list 'default-frame-alist '(height . 60))
(add-to-list 'default-frame-alist '(font . "Inconsolata 14"))
;; Improvements to X11 clipbard integration.
(setq mouse-drag-copy-region nil)
(setq x-select-enable-primary nil)
(setq x-select-enable-clipboard t)
(setq select-active-regions t)
