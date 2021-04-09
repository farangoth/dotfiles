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
    py-autopep8
    flycheck
    ein
    elpy
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

;; Because emacs is launched with systemd
(when (daemonp)
  (exec-path-from-shell-initialize))
(exec-path-from-shell-copy-env "PATH")
(exec-path-from-shell-copy-env "WORKON_HOME")
;; Theme

;; Interactive buffer
(require 'ido)
(ido-mode t)
;; Better naming for homonymous buffers
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)
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

;; Git integration
(require 'magit)
; SSH Agent
(require 'exec-path-from-shell)
(exec-path-from-shell-copy-env "SSH_AGENT_PID")
(exec-path-from-shell-copy-env "SSH_AUTH_SOCK")

;; Python
(elpy-enable)
;; Make pyenv working with virtualenvwrapper
; Without, RPC gets stuck in his venv
;(setq elpy-rpc-virtualenv-path 'default)
(defadvice pyvenv-virtualenvwrapper-supported (around not-for-elpy-rpc-venv activate)
  "Ensure no virtualenvwrapper support for the RPC virtualenv"
  (if (string= pyvenv-virtual-env-name "rpc-venv")
      nil
    ad-do-it))


;; Use IPython for REPL
;; (setq python-shell-interpreter "jupyter"
;;       python-shell-interpreter-args "console --simple-prompt"
;;       python-shell-prompt-detect-failure-warning nil)
;; (add-to-list 'python-shell-completion-native-disabled-interpreters
;;              "jupyter")

;; autoformat on save - using yapf
(add-hook 'elpy-mode-hook (lambda ()
                            (add-hook 'before-save-hook
                                      'elpy-format-code nil t)))
;; flycheck > flymake
(when (require 'flycheck nil t)
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  (add-hook 'elpy-mode-hook 'flycheck-mode))
(setq flycheck-python-flake8-executable "~/.local/bin/flake8")

(provide 'init)
;;; init.el ends here
