;;; security-config.el --- Security hardenings and safe defaults. -*- lexical-binding: t; -*-

(defvar gnutls-verify-error)
(defvar tls-checktrust)
(defvar gnutls-min-prime-bits)
(defvar network-security-level)
(defvar vc-follow-symlinks)
(defvar ignored-local-variables)
(defvar server-use-tcp)
(defvar server-socket-dir)
(defvar auth-sources)
(defvar auth-source-cache-expiry)
(defvar password-cache-expiry)
(defvar epg-pinentry-mode)
(defvar epa-file-inhibit-auto-save)
(defvar epa-file-select-keys)

;; Package & Network Security.
(setq package-check-signature 'allow-unsigned
      gnutls-verify-error t
      tls-checktrust t
      gnutls-min-prime-bits 2048
      network-security-level 'high)

;; File & Directory Local Variables Safety.
(setq enable-local-variables :safe
      enable-local-eval nil
      vc-follow-symlinks 'ask
      ignored-local-variables '(load-path exec-path auto-mode-alist compile-command))

;; Backup & Auto-save Isolation (0700 permissions).
(let ((backup-dir (expand-file-name "~/.saves/"))
      (autosave-dir (expand-file-name "auto-saves/" user-emacs-directory)))
  (dolist (dir (list backup-dir autosave-dir))
    (ignore-errors
      (unless (file-directory-p dir)
        (make-directory dir t))
      (set-file-modes dir #o700))))

(setq auto-save-file-name-transforms
      `((".*" ,(expand-file-name "auto-saves/" user-emacs-directory) t)))

(setq backup-enable-predicate
      (lambda (name)
        (and (normal-backup-enable-predicate name)
             (not (string-match-p "\\(?:\\.\\(?:gpg\\|age\\)\\'\\|^/tmp/\\)" name)))))

;; Server & Socket Isolation.
(require 'server)
(setq server-use-tcp nil)
(unless (getenv "XDG_RUNTIME_DIR")
  (let ((dirs (list (expand-file-name "server" user-emacs-directory)
                    server-socket-dir)))
    (dolist (dir dirs)
      (when dir
        (ignore-errors
          (unless (file-directory-p dir)
            (make-directory dir t))
          (set-file-modes dir #o700))))))

;; Auth-Sources & EasyPG Hardening.
(setq auth-sources '("~/.authinfo.gpg")
      auth-source-cache-expiry 300
      password-cache-expiry 60
      epg-pinentry-mode 'loopback
      epa-file-inhibit-auto-save t
      epa-file-select-keys nil)

(provide 'security-config)
;;; security-config.el ends here
