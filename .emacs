;; Load all themes inside a folder
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")

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
 '(custom-enabled-themes (quote (material)))
 '(custom-safe-themes
   (quote
    ("d27829b2d1ba43d1e3c0a5a1e0341ebaec65b81ac029cd9d28ae8d03135eb26b" "8db43a8d70fa7a1d2cdf72f1f05d731b93189869fdf1884b1dbc673a692dd1d1" "2c6e6007c25f2470ec86ef37338ebf6c24c1a762cd8a27d6cd173ebeeada0e57" "6f88853dc50c6577367b8c90a147f99ea08ccf3e59942de9c5af853e16729a30" "aceaee2087a372e0264323f0757e1bebb47baa628cebe977eb0eb0fa3f372646" "fb2c4f5a893d1e83d39a5365334810c84bd11f906c034420c73a9ee9c4351f0c" "1bb74b2cc048ea0520db04083164fc6ae1aa32f71f516fd66a2be09f06c941b7" "2d035eb93f92384d11f18ed00930e5cc9964281915689fa035719cab71766a15" "f490984d405f1a97418a92f478218b8e4bcc188cf353e5dd5d5acd2f8efd0790" "28a104f642d09d3e5c62ce3464ea2c143b9130167282ea97ddcc3607b381823f" "afd761c9b0f52ac19764b99d7a4d871fc329f7392dfc6cd29710e8209c691477" "d4f8fcc20d4b44bf5796196dbeabec42078c2ddb16dcb6ec145a1c610e0842f3" "0f0a885f4ce5b6f97e33c7483bfe4515220e9cbd9ab3ca798e0972f665f8ee4d" default)))
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
    (slim-mode poet-theme org-bullets helm-ag helm-projectile helm ruby-electric projectile)))
 '(pdf-view-midnight-colors (quote ("#DCDCCC" . "#383838")))
 '(scroll-bar-mode nil)
 '(show-paren-mode t)
 '(show-trailing-whitespace t)
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

;; mwheel config
(global-set-key (kbd "C-M-(") (kbd "<mouse-4>"))
(global-set-key (kbd "C-M-)") (kbd "<mouse-5>"))

;; Avoid creating #file# or file.rb~ inside the current
;; directory. Keep all emacs stuff inside this folder
(setq backup-directory-alist'(("." . "~/.emacs_saves")))
(setq auto-save-file-name-transforms'((".*" "~/.emacs_saves/" t)))

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
      '((width . 150) (height . 50)))

;;;;;;;;;;;;;;;;;;;; Package loader ;;;;;;;;;;;;;;;;;;;;

;; Add Melpa
;; Probably the most used package maneger of emacs
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Enable theme
(load-theme 'material t)

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
(global-set-key (kbd "C-c t") #'helm-projectile-find-file-dwim)
(global-set-key (kbd "C-x C-b") #'helm-mini)

;;;;;;;;;;;;;;;;;;;; Custom functions ;;;;;;;;;;;;;;;;;;;;

;; Kill all buffers in order to keep current emacs always clear
;; It keep the current buffer alive. Useful when you have a lot
;; of other stuff loaded
(defun kill-other-buffers ()
      "Kill all other buffers."
      (interactive)
      (mapc 'kill-buffer (delq (current-buffer) (buffer-list))))
(global-set-key (kbd "C-x q") 'kill-other-buffers)
