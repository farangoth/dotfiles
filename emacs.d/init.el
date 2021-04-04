;;; init.el -- configuration file for emacs

;; custom.el -- automated file, separated
(setq custom-file (locate-user-emacs-file "emacs-custom.el"))
(unless (file-exists-p custom-file)
  (write-region "" nil custom-file))
(load custom-file)

;; Package support
(require 'package)

;; Package list
(defvar package-myPackages
  '(
    magit
    exec-path-from-shell
    virtualenvwrapper
    ))

(add-to-list 'package-archives
	     '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))

;; Download packages if not installed yet
(dolist (package package-myPackages)
  (unless (package-installed-p package)
    (package-install package)))



;; basic configuration
(setq inhibit-startup-message t)
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))
(when (fboundp 'horizontal-scroll-bar-mode)
  (horizontal-scroll-bar-mode -1))
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(show-paren-mode 1)
(global-linum-mode t)
(column-number-mode t)
(global-font-lock-mode t)
(setq x-select-enable-clipboard t)
(setq frame-title-format "%b - emacs")
(setq visible-bell 1)
(setq show-trailing-whitespace t)
(setq backup-by-copying-when-mismatch t) ; preserve ownership of files

;; Theme

;; Better naming for homonymous buffers
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

;; Write backups to ~/.emacs.d/backup/
(setq backup-directory-alist '(("." . "~/.emacs.d/backups/"))
      ; backup-by-copying      t  ; Don't de-link hard links
      version-control        t  ; Use version numbers on backups
      delete-old-versions    t  ; Automatically delete excess backups:
      kept-new-versions      20 ; how many of the newest versions to keep
      kept-old-versions      5 ; and how many of the old
)

;; Git integration
(require 'magit)
; SSH Agent
(require 'exec-path-from-shell)
(exec-path-from-shell-copy-env "SSH_AGENT_PID")
(exec-path-from-shell-copy-env "SSH_AUTH_SOCK")

;; Python
(require 'virtualenvwrapper)
;(venv-initialize-interactive-shells) ;; if you want interactive shell support
;(venv-initialize-eshell) ;; if you want eshell support
;; note that setting `venv-location` is not necessary if you
;; use the default location (`~/.virtualenvs`), or if the
;; the environment variable `WORKON_HOME` points to the right
					; (setq venv-location "~/.virtualenvs")
(setq-default mode-line-format (cons '(:exec venv-current-name) mode-line-format))


(provide 'init)
;;; init.el ends here
