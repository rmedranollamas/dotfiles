;; -*- mode: Lisp -*-
;; General UI configurations.

;; Custom configurations for the interface.
(blink-cursor-mode 0)
(column-number-mode t)
(show-paren-mode 1)
(menu-bar-mode 0)
(setq inhibit-splash-screen t)
(cua-mode t)
(defvar cua-auto-tabify-rectangles nil)
(transient-mark-mode 1)

;; Load Solarized theme.
(require 'cl-lib)
(custom-set-variables
 '(solarized-termcolors 256)
 '(solarized-broken-srgb t)
 '(frame-background-mode 'dark))
(add-hook 'after-make-frame-functions
          (lambda (frame)
            (set-frame-parameter frame 'background-mode 'dark)
            (set-terminal-parameter frame 'background-mode 'dark)
            (enable-theme 'solarized)))
(load-theme 'solarized t)
(enable-theme 'solarized)

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

;; Winner mode allow undo on window changes.
(winner-mode 1)

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

(global-whitespace-mode 1)

;; Options when using the window manager.
(cond (window-system (progn
    (setq frame-title-format
      '("Emacs - " (buffer-file-name "%f"
                                     (dired-directory dired-directory "%b"))))
    (scroll-bar-mode 0)
    (tool-bar-mode 0)
    ; Font and. Use Inconsolata by default.
    (set-face-font 'default "Inconsolata 12")
    ; Only in window system, set the frame size.
    (set-frame-size (selected-frame) 80 50)
    ; Improvements to X11 clipbard integration.
    (setq mouse-drag-copy-region nil)
    (setq x-select-enable-primary nil)
    (setq x-select-enable-clipboard t)
    (setq select-active-regions t)
    (global-set-key [mouse-2] 'mouse-yank-primary)
    ; Allow fullscreen by using wmctrl on GNOME 3
    (defun switch-full-screen ()
      (interactive)
      (shell-command "wmctrl -r :ACTIVE: -btoggle,fullscreen"))
    ; And do it with F11
    (global-set-key [f11] 'switch-full-screen)
)))
