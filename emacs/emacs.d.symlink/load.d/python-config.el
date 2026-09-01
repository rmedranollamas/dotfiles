;;; python-config.el --- python-mode configuration. -*- lexical-binding: t; -*-

(defvar pipenv-projectile-after-switch-function)
(defvar eglot-server-programs)
(declare-function pipenv-projectile-after-switch-extended "pipenv")

;; Enable pipenv.
(use-package pipenv
  :ensure t
  :defer t
  :hook ((python-mode . pipenv-mode)
         (python-ts-mode . pipenv-mode))
  :init
  (setq pipenv-projectile-after-switch-function
        #'pipenv-projectile-after-switch-extended))

;; Modern Python LSP with Eglot (built-in in Emacs 29+).
(use-package eglot
  :defer t
  :hook ((python-mode . eglot-ensure)
         (python-ts-mode . eglot-ensure))
  :config
  (add-to-list 'eglot-server-programs
               '((python-mode python-ts-mode) . ("ruff" "server"))))

(provide 'python-config)
;;; python-config.el ends here
