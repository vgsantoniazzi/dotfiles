;; Disable whitespace mode for orgmode
(setq whitespace-global-modes '(not org-mode))

;; Variables set by emacs client
;; Change it carefully by hand
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default bold shadow italic underline bold bold-italic bold])
 '(ansi-color-names-vector
   ["#242424" "#e5786d" "#95e454" "#cae682" "#8ac6f2" "#333366" "#ccaa8f" "#f6f3e8"])
 '(column-number-mode t)
 '(company-quickhelp-color-background "#4F4F4F")
 '(company-quickhelp-color-foreground "#DCDCCC")
 '(display-line-numbers-type (quote relative))
 '(fci-rule-color "#ECEFF1")
 '(font-use-system-font t)
 '(global-display-line-numbers-mode t)
 '(global-whitespace-mode t)
 '(hl-sexp-background-color "#1c1f26")
 '(line-spacing 0.2)
 '(nrepl-message-colors
   (quote
    ("#CC9393" "#DFAF8F" "#F0DFAF" "#7F9F7F" "#BFEBBF" "#93E0E3" "#94BFF3" "#DC8CC3")))
 '(org-agenda-files (quote ("~/Documents/Todo.org")))
 '(package-selected-packages
   (quote
    (zenburn-theme gruvbox-theme rust-mode elixir-mode javap-mode web-mode typescript-mode slim-mode poet-theme org-bullets helm-ag helm-projectile helm ruby-electric projectile)))
 '(pdf-view-midnight-colors (quote ("#DCDCCC" . "#383838")))
 '(scroll-bar-mode nil)
 '(show-paren-mode t)
 '(show-trailing-whitespace t)
 '(tab-width 2)
 '(tool-bar-mode nil)
 '(tooltip-mode nil)
 '(vc-annotate-background nil)
 '(vc-annotate-color-map
   (quote
    ((20 . "#f36c60")
     (40 . "#ff9800")
     (60 . "#fff59d")
     (80 . "#8bc34a")
     (100 . "#81d4fa")
     (120 . "#4dd0e1")
     (140 . "#b39ddb")
     (160 . "#f36c60")
     (180 . "#ff9800")
     (200 . "#fff59d")
     (220 . "#8bc34a")
     (240 . "#81d4fa")
     (260 . "#4dd0e1")
     (280 . "#b39ddb")
     (300 . "#f36c60")
     (320 . "#ff9800")
     (340 . "#fff59d")
     (360 . "#8bc34a"))))
 '(vc-annotate-very-old-color nil)
 '(whitespace-line-column 9999))

;;Variables set by emacs client
;; Change it carefully by hand
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Menlo for Powerline" :foundry "PfEd" :slant normal :weight normal :height 120 :width normal))))
 '(whitespace-empty ((t (:background "dark gray"))))
 '(whitespace-line ((t nil)))
 '(whitespace-newline ((t (:foreground "gray12"))))
 '(whitespace-space ((t (:foreground "gray33")))))

;;;;;;;;;;;;;;;;;;;; Override config ;;;;;;;;;;;;;;;;;;;;

;; Disable bell
(setq ring-bell-function 'ignore)

;; Auto-revert mode: Reload file if git chaged the buffer
(global-auto-revert-mode t)

;; Avoid creating #file# or file.rb~ inside the current
;; directory. Keep all emacs stuff inside this folder
(setq backup-directory-alist'(("." . "~/.emacs_saves")))
(setq auto-save-file-name-transforms'((".*" "~/.emacs_saves/" t)))

;; Set Directory to keep Agenda/Org-mode files
(setq org-agenda-files '("~/Notes"))

;; Do not use tabs. Always translate to spaces.
(setq-default indent-tabs-mode nil)

;; Set 2 indent levels
(setq js-indent-level 2)
(setq javascript-indent-level 2)
(setq-default c-basic-offset 2)
(setq c-basic-offset 2)
(setq-default tab-width 2)
(setq-default c-basic-indent 2)
(setq web-mode-markup-indent-offset 2)
(setq web-mode-css-indent-offset 2)
(setq web-mode-code-indent-offset 2)


;; Hook to always remove trailing whitespace when saving
;; the file. It helps to keep nice and useful files.
;; industry-standard to keep everything clear and easy to review
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Set the key to move betweeen windows (or panes or splits)
;; Using C-arrow. C-<Arrow Left> to left and so on.
(windmove-default-keybindings 'control)

;; Set Frame width/height
;; Default Emacs is too little and we always need to
;; resize manually
(setq default-frame-alist
      '((width . 300) (height . 80)))

;;;;;;;;;;;;;;;;;;;; Package loader ;;;;;;;;;;;;;;;;;;;;

;; Add Melpa
;; Probably the most used package maneger of emacs
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Enable theme
(load-theme 'gruvbox t)

;; Support project file finder, grep under emacs and a bunch of other stuff
(projectile-mode +1)
(define-key projectile-mode-map (kbd "C-c c") 'projectile-command-map)
(setq projectile-project-search-path '("~/Code/"))

;; Enable ruby electric mode
(add-hook 'ruby-mode-hook 'ruby-electric-mode)

;; org-bullets
(require 'org-bullets)
(add-hook 'org-mode-hook (
                          lambda ()
                          (org-bullets-mode 1)))

;; Helm package config
(global-set-key (kbd "M-x") #'helm-M-x)
(global-set-key (kbd "C-c f") #'helm-projectile-ag)
(global-set-key (kbd "C-c b") #'helm-resume)
(global-set-key (kbd "C-c t") #'helm-projectile-find-file-dwim)
(global-set-key (kbd "C-x C-b") #'helm-mini)

;; web-mode
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.js[x]\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.ts[x]\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))

;; Slim mode
(require 'slim-mode)

;; Rust mode
(require 'rust-mode)

;;;;;;;;;;;;;;;;;;;; Custom functions ;;;;;;;;;;;;;;;;;;;;

;; Kill all buffers in order to keep current emacs always clear
;; It keep the current buffer alive. Useful when you have a lot
;; of other stuff loaded
(defun kill-other-buffers ()
      "Kill all other buffers."
      (interactive)
      (mapc 'kill-buffer (delq (current-buffer) (buffer-list))))
(global-set-key (kbd "C-x q") 'kill-other-buffers)

;; MacOSX requires for helm-ag
(add-to-list 'exec-path "/usr/local/bin/")
