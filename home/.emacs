;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)


;;; ---------------------------------
;;; Theme
;;; ---------------------------------

;; (load-theme 'wheatgrass t)
(load-theme 'modus-vivendi t)
;; (load-theme 'dracula t)

;;; ---------------------------------
;;; General
;;; ---------------------------------

;; ignore (require 'cl)
(setq byte-compile-warnings '(not cl-functions obsolete))

;; user information
(setq user-full-name "HILAGA Masaki")
(setq user-mail-address "garhyla@morphoinc.com")

;; set column size 72 (M-q for newline)
(setq-default fill-column 72)

;; enalbe mouse wheel
(mouse-wheel-mode t)
(setq mouse-wheel-follow-mouse t)

;; scroll every 4 lines
(setq scroll-step 4)

;; enable copy & paste with clipboard
(setq x-select-enable-clipboard t)


;; ------------------------------------------------------------------
;;  Language
;; ------------------------------------------------------------------


;; default language is Japanese
(set-language-environment "Japanese")

;; MS Gothic for Windwos
(when (eq system-type 'windows-nt)
  (set-default-font "ÇlÇr ÉSÉVÉbÉN-13")
  (set-fontset-font (frame-parameter nil 'font)
		    'japanese-jisx0208
		    '("ÇlÇr ÉSÉVÉbÉN-13" . "unicode-bmp")))

;; VL Gothic for Linux
(when (equal system-type 'gnu/linux)
;;  (require 'mozc)
;;  (setq default-input-method "japanese-mozc")
  (prefer-coding-system 'utf-8)
  (set-default-coding-systems 'utf-8)
  (set-terminal-coding-system 'utf-8)
  (setq file-name-coding-system 'utf-8)
  (setq default-buffer-file-coding-system 'utf-8)
  (set-frame-font "VL Gothic-13")
  (set-fontset-font (frame-parameter nil 'font)
		    'japanese-jisx0208
		    '("VL Gothic-13" . "unicode-bmp"))
  )


;;; ------------------------------------------------------------------
;;; GUI
;;; ------------------------------------------------------------------


;; display line number
(require 'linum)
(global-linum-mode)
(setq linum-format "%4d ")

;; color mode
(global-font-lock-mode t)

;; hide tool bar and menu bar
(tool-bar-mode 0)
(menu-bar-mode 0)
(set-scroll-bar-mode 'right)
(setq default-frame-alist
      (append
       '((left-fringe . 1) (right-fringe . 0))
       default-frame-alist))

;; display line number
(custom-set-variables
 '(column-number-mode t)
 '(scroll-step 0))

;; disable startup message
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)

;; background: gray, foreground: black
;; (custom-set-faces '(default ((t (:background "gray80" :foreground "black")))))

;; background: black, foreground: white
;; (custom-set-faces '(default ((t (:background "black" :foreground "gray70")))))

;;; ------------------------------------------------------------------
;;; Development
;;; ------------------------------------------------------------------

;; commands to compile
(global-set-key [f11] 'compile)
(global-set-key [f12] 'recompile)
(setq compile-command "make")

;; C/C++
;; indent: 4, tab: 8
(add-hook 'c-mode-common-hook
          '(lambda ()
             (c-set-style "cc-mode")
             (c-set-offset 'innamespace 0) ; don't indent in namespace {}
             (c-set-offset 'inextern-lang 0) ; don't indent in extern {}
             (setq c-basic-offset 4)
             (setq c-auto-newline nil) ; disable automatic newline
             ))
(setq-default indent-tabs-mode 'nil) ; don't use tab
(setq-default tab-width 8)

;; C++ mode for .h
(setq auto-mode-alist (append '(("\\.h$" . c++-mode)) auto-mode-alist))

;; JavaScript mode for .qml
(setq auto-mode-alist (append '(("\\.qml$" . js-mode)) auto-mode-alist))

;; C mode for .cl
(setq auto-mode-alist (append '(("\\.cl$" . c-mode)) auto-mode-alist))

;; C++ mode for .cu
(setq auto-mode-alist (append '(("\\.cu$" . c++-mode)) auto-mode-alist))

;; Python mode for .py
(setq auto-mode-alist (cons '("\\.py$" . python-mode) auto-mode-alist))
(setq interpreter-mode-alist (cons '("python" . python-mode)
                                   interpreter-mode-alist))

;; clang-format
;; (require 'clang-format)


;;; ---------------------------------
;;; GDB
;;; ---------------------------------


;; debug command
(setq gdb-command-name "gdb")

;; open many windows
(setq gdb-many-windows t)

;; display value when hovering cursor over variable
(add-hook 'gdb-mode-hook '(lambda () (gud-tooltip-mode t)))

;; display I/O buffer
(setq gdb-use-separate-io-buffer t)

;; display value in mini buffer if set t
(setq gud-tooltip-echo-area nil)


;;; ---------------------------------
;;; External
;;; ---------------------------------


;; read mor.el
(load-file "~/emacs/mor.el")
