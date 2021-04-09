;;; init.el -- configuration file for emacs

;; custom.el -- automated file, separated
(setq custom-file (locate-user-emacs-file "emacs-custom.el"))
(unless (file-exists-p custom-file)
  (write-region "" nil custom-file))
(load custom-file)

;; use-package support
;; Package support
(require 'package)
(package-initialize)
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.org/packages/") t)
(add-to-list 'package-archives
	     '("org" . "https://orgmode.org/elpa/") t)
(when (not package-archive-contents)
  (package-refresh-contents))
(unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package))
(eval-when-compile
  (require 'use-package))

;; basic configuration
;; startup
(setq inhibit-startup-message t
      initial-scratch-message nil
      initial-major-mode 'org-mode)
;; interface
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))
(when (fboundp 'horizontal-scroll-bar-mode)
  (horizontal-scroll-bar-mode -1))
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(show-paren-mode 1)
(electric-pair-mode t)
(global-linum-mode t)
(column-number-mode t)
(global-font-lock-mode t)
(setq x-select-enable-clipboard t)
(setq frame-title-format "%b - emacs")
(setq visible-bell 1)
(setq show-trailing-whitespace t)
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq backup-by-copying-when-mismatch t) ; preserve ownership of files
(fset 'yes-or-no-p 'y-or-n-p)
;; scroll
(setq scroll-step            1
      scroll-conservatively  10000
      mouse-wheel-scroll-amount '(1 ((shift) . 1))
      mouse-wheel-progressive-speed nil
      mouse-wheel-follow-mouse 't)

;; Write backups to ~/.emacs.d/backup/
(setq backup-directory-alist `(("." . ,(concat user-emacs-directory "backups")))
      backup-by-copying      t  ; Don't de-link hard links
      version-control        t  ; Use version numbers on backups
      delete-old-versions    t  ; Automatically delete excess backups:
      kept-new-versions      20 ; how many of the newest versions to keep
      kept-old-versions      5 ; and how many of the old
      )

(use-package exec-path-from-shell
  :ensure t
  :demand t
  :init
  (setq exec-path-from-shell-variables
	'("PATH" "MANPATH" "WORKON_HOME" "SSH_AGENT_PID" "SSH_AUTH_SOCK"))
  (exec-path-from-shell-initialize))

;; Better naming for homonymous buffers
;; (use-package uniquify
;;   :ensure t
;;   :custom
;;   (uniquify-buffer-name-style 'forward))

;; Git integration
(use-package magit
  :ensure t
  :bind
  ("C-x g" . magit-status))

;; snippets
(use-package yasnippet
  :ensure t
  :config
  (add-to-list 'yas-snippet-dirs (concat user-emacs-directory "snippets"))
  (yas-global-mode 1))

;; Python
(use-package elpy
  :ensure t
  :init
  (elpy-enable)
  :config
  ;; virtualenvwrapper needs this to handle the RPC properly
  (defadvice pyvenv-virtualenvwrapper-supported (around not-for-elpy-rpc-venv activate)
  "Ensure no virtualenvwrapper support for the RPC virtualenv"
  (if (string= pyvenv-virtual-env-name "rpc-venv")
      nil
    ad-do-it))
  ;; yapf on save
  (add-hook 'elpy-mode-hook (lambda ()
                            (add-hook 'before-save-hook
                                      'elpy-format-code nil t))))

;; flycheck > flymake
(use-package flycheck
  :ensure t
  :init
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  (add-hook 'elpy-mode-hook 'flycheck-mode)
  (setq flycheck-python-flake8-executable "~/.local/bin/flake8"))

(use-package virtualenvwrapper
  :ensure t)
(use-package ein
  :ensure t)

(use-package org
  :ensure t
  :config
  (setq org-log-done t)
  :bind
  ("C-c a" . org-agenda))

(setq user-full-name "Clément Savalle"
      user-mail-address "savalle.clement@gmail.com"
      calendar-location-name "New Mills, England")

(provide 'init)
;;; init.el ends here
