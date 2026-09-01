;;; ui-config.el --- General UI configurations. -*- lexical-binding: t; -*-

(require 'cua-base)
(require 'ansi-color)
(defvar c-basic-offset)
(defvar c-basic-indent)

;; Custom configurations for the interface.
(blink-cursor-mode 0)
(line-number-mode 1)
(column-number-mode 1)
(show-paren-mode 1)
(cua-mode 1)
(setq cua-auto-tabify-rectangles nil)
(transient-mark-mode 1)
(global-font-lock-mode 1)

;; Built-in line numbers (replaces linum-mode).
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'text-mode-hook #'display-line-numbers-mode)

;; Load Monokai theme.
(use-package monokai-theme
  :ensure t
  :defer t
  :init
  (load-theme 'monokai t))

;; Rainbow delimiters on programming modes.
(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

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

;; Increase buffer size in split mode.
(defun halve-other-window-height ()
  (interactive)
  (enlarge-window (/ (window-height (next-window)) 2)))
(global-set-key (kbd "C-c v") 'halve-other-window-height)

;; Show color sequences as colors in shell.
(add-hook 'shell-mode-hook #'ansi-color-for-comint-mode-on)

;; Show column indicator at fill-column (scoped to prog-mode).
(setq-default fill-column 80)
(when (fboundp 'display-fill-column-indicator-mode)
  (add-hook 'prog-mode-hook #'display-fill-column-indicator-mode))

;; Options when using the window manager.
(setq frame-title-format
      '("Emacs - " (buffer-file-name "%f"
                                     (dired-directory dired-directory "%b"))))
(when (fboundp 'menu-bar-mode)
  (menu-bar-mode 0))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode 0))
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode 0))
(add-to-list 'default-frame-alist '(width  . 90))
(add-to-list 'default-frame-alist '(height . 70))
(add-to-list 'default-frame-alist '(font . "IBM Plex Mono 14"))

;; Improvements to X11 clipboard integration.
(setq mouse-drag-copy-region nil
      select-enable-primary nil
      select-enable-clipboard t
      select-active-regions t)

;; Tree-sitter major-mode remappings when tree-sitter grammars are available.
(when (require 'treesit nil t)
  (dolist (pair '((python-mode python-ts-mode python)
                  (sh-mode     bash-ts-mode   bash)
                  (bash-mode   bash-ts-mode   bash)
                  (json-mode   json-ts-mode   json)
                  (yaml-mode   yaml-ts-mode   yaml)
                  (c-mode      c-ts-mode      c)
                  (toml-mode   toml-ts-mode   toml)))
    (let ((orig (nth 0 pair))
          (ts (nth 1 pair))
          (lang (nth 2 pair)))
      (when (treesit-ready-p lang t)
        (add-to-list 'major-mode-remap-alist (cons orig ts))))))

(provide 'ui-config)
;;; ui-config.el ends here
