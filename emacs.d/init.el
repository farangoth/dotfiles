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
(add-hook 'prog-mode-hook 'linum-mode)
(column-number-mode t)
(global-font-lock-mode t)
(setq font-use-system-font t)
(global-hl-line-mode t)
(setq x-select-enable-clipboard t)
(setq frame-title-format "%b - emacs")
(setq visible-bell 1)
(setq show-trailing-whitespace t)
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq backup-by-copying-when-mismatch t) ; preserve ownership of files
(fset 'yes-or-no-p 'y-or-n-p)
;; scroll
(setq scroll-step 1
      scroll-conservatively  10000
      mouse-wheel-scroll-amount '(1 ((shift) . 1))
      mouse-wheel-progressive-speed nil
      mouse-wheel-follow-mouse 't)
(setq custom--inhibit-theme-enable nil)

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
	'("PATH"
	  "MANPATH"
	  "WORKON_HOME"
	  ; "SSH_AGENT_PID"
	  "SSH_AUTH_SOCK"))
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

(use-package forge
  :ensure t
  :after magit
  :init
  (setq auth-sources '("~/.authinfo"))
  )

(use-package git-auto-commit-mode
  :ensure t)

;; snippets
(use-package yasnippet
  :ensure t
  :init
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
                                      'elpy-format-code nil t)))
  (setq highlight-indentation-blank-lines 1))

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
  :init
  (setq org-log-done t
	org-adapt-indentation t)
  (setq org-agenda-files (list "~/org/pro.org"
			       "~/org/outdoor.org"
			       "~/org/perso.org"))
  :bind
  ("C-c a" . org-agenda)
  ("C-c l" . org-store-link))

(use-package doom-themes
  :ensure t
  :init
  (setq doom-themes-enable-bold t
	doom-themes-enable-italic t)
  :config
  (load-theme 'doom-vibrant t)
  (doom-themes-org-config)
  ;(set-face-attribute 'linum nil :background "bg")
  (set-face-attribute 'fringe nil :background "#242730")
  (set-face-attribute font-lock-doc-face nil :foreground "orange")
  (set-face-attribute 'highlight-indentation-face nil :background "#151821")
  )

(use-package pdf-tools
  :ensure t
  :init
  (pdf-tools-install)
  :config
  (add-hook 'pdf-view-mode-hook (lambda () (auto-revert-mode 1)))
  )


(use-package tex
  :ensure auctex
  :init
  (setq TeX-auto-save t
	TeX-parse-self t
	TeX-PDF-mode t)
  (setq-default TeX-master nil)
  :config
  (add-hook 'LaTeX-mode-hook 'linum-mode)
  (add-to-list 'TeX-command-list '("Make" "make" TeX-run-compile nil t))
  (add-hook 'TeX-mode-hook
	    (lambda ()
              (setq TeX-command-default "Make")))
  (setq TeX-view-program-selection '((output-pdf "PDF Tools"))
	TeX-source-correlate-start-server t)
  (add-hook 'TeX-after-compilation-finished-functions
            #'TeX-revert-document-buffer)
  )

(use-package auctex-latexmk
  :ensure t)

;; (use-package po-mode
;;   :ensure t
;;   :config
;;    (autoload 'po-mode "po-mode"
;;             "Major mode for translators to edit PO files" t)
;;   (setq auto-mode-alist (cons '("\\.po\\'\\|\\.po\\." . po-mode)
;;                               auto-mode-alist))
;;   (autoload 'po-find-file-coding-system "po-compat")
;;   (modify-coding-system-alist 'file "\\.po\\'\\|\\.po\\."
;;                               'po-find-file-coding-system)
;;   (defcustom po-wrap-width 79
;;   "*Width to which to wrap msgstrs."
;;   :type 'integer
;;   :group 'po)
;;   (defun po-my-validate ()
;;   "Use 'msgfmt' for validating the current PO file contents."
;;   (interactive)
;;   ;; The 'compile' subsystem is autoloaded through a call to (compile ...).
;;   ;; We need to initialize it outside of any binding. Without this statement,
;;   ;; all defcustoms and defvars of compile.el would be undone when the let*
;;   ;; terminates.
;;   (require 'compile)
;;   (defvar po-my-validation-program "padpo")
;;   (let* ((dev-null
;;           (cond ((boundp 'null-device) null-device) ; since Emacs 20.3
;;                 ((memq system-type '(windows-nt windows-95)) "NUL")
;;                 (t "/dev/null")))
;;          (output
;;           (if po-keep-mo-file
;;               (concat (file-name-sans-extension buffer-file-name) ".mo")
;;             dev-null))
;;          (compilation-buffer-name-function
;;           (function (lambda (mode-name)
;;                       (concat "*" mode-name " validation*"))))
;;          (compile-command (concat po-my-validation-program
;;                                   " -i "
;;                                   (shell-quote-argument output) " "
;;                                   (shell-quote-argument buffer-file-name))))
;;     (compile compile-command)))
;;   (defun po-wrap ()
;;     )
;;   (define-key po-mode-map "V" 'po-my-validate)
;;   )

(setq user-full-name "Clément Savalle"
      user-mail-address "savalle.clement@gmail.com"
      calendar-location-name "New Mills, England")

(provide 'init) ;;; init.el ends here
