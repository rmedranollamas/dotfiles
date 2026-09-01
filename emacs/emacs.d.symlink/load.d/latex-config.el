;;; latex-config.el --- Configs for AuCTeX. -*- lexical-binding: t; -*-

(defvar TeX-auto-save)
(defvar TeX-parse-self)
(defvar TeX-master)
(defvar TeX-PDF-mode)
(defvar ispell-extra-args)
(defvar TeX-source-correlate-method)
(defvar TeX-source-correlate-mode)
(defvar TeX-source-correlate-start-server)
(defvar TeX-view-program-selection)
(defvar TeX-view-program-list)
(defvar auctex-latexmk-inherit-TeX-PDF-mode)
(declare-function auctex-latexmk-setup "auctex-latexmk")
(declare-function LaTeX-math-mode "latex")
(declare-function turn-on-flyspell "flyspell")

;; Basics.
(use-package auctex
  :ensure t
  :defer t
  :mode ("\\.tex\\'" . latex-mode)
  :hook ((LaTeX-mode . visual-line-mode)
         (LaTeX-mode . LaTeX-math-mode)
         (LaTeX-mode . turn-on-flyspell)
         (LaTeX-mode . TeX-source-correlate-mode))
  :init
  (setq TeX-auto-save t
        TeX-parse-self t
        TeX-master nil
        TeX-PDF-mode t
        ispell-extra-args '("--sug-mode=fast")
        TeX-source-correlate-method 'synctex
        TeX-source-correlate-mode t
        TeX-source-correlate-start-server nil)
  (cond
   ((eq system-type 'darwin)
    (setq TeX-view-program-selection '((output-pdf "Skim"))
          TeX-view-program-list
          '(("Skim" "/Applications/Skim.app/Contents/SharedSupport/displayline -b -g %n %o %b"))))
   ((eq system-type 'gnu/linux)
    (setq TeX-view-program-selection
          `((output-pdf ,(cond ((fboundp 'pdf-tools-install) "PDF Tools")
                               ((executable-find "evince") "Evince")
                               (t "xdg-open"))))))))

;; Use latexmk.
(use-package auctex-latexmk
  :ensure t
  :after auctex
  :config
  (auctex-latexmk-setup)
  (setq auctex-latexmk-inherit-TeX-PDF-mode t))

(provide 'latex-config)
;;; latex-config.el ends here
