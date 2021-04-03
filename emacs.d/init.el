;;; init.el -- configuration file for emacs

;; custom.el -- automated file, separated
(setq custom-file (locate-user-emacs-file "emacs-custom.el"))
(unless (file-exists-p custom-file)
  (write-region "" nil custom-file))
(load custom-file)

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
(setq visible-bell 1)
(setq show-trailing-whitespace t)

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

;; Package support
(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))

;; Package list
(defvar package-myPackages
  '(
    
    ))

;; Download packages if not installed yet
(mapc  #'(lambda (package)
	  (unless(package-installed-p package)
	    (package-install package)))
       package-myPackages)

(provide 'init)
;;; init.el ends here
