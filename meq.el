;;; meq.el --- a simple package                     -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Jeet Ray

;; Author: Jeet Ray <aiern@protonmail.com>
;; Keywords: lisp
;; Version: 0.0.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; 

;;; Code:

(require 'cosmoem)
(require 'naked)
(require 'janus)

(defvar meq/var/modal-modes nil)
(defvar meq/var/ignored-modal-modes nil)
(defvar meq/var/modal-prefixes (mapcar (lambda (mode) (interactive)
    (car (split-string (symbol-name mode) "-"))) meq/var/modal-modes))
(defvar meq/var/ignored-modal-prefixes (mapcar (lambda (mode) (interactive)
    (car (split-string (symbol-name mode) "-"))) meq/var/ignored-modal-modes))
(defvar meq/var/last-global-map nil)
(defvar meq/var/which-key-really-dont-show t)
(defvar meq/var/last-evil-state nil)
(defvar meq/var/last-aiern-state nil)
(defvar meq/var/backup-modal-modes nil)
(defvar meq/var/backup-terminal-local-map nil)
(defvar meq/var/all-modal-modes-off nil)

;;;###autoload
(defun meq/timestamp nil (interactive) (format-time-string "%Y%m%d%H%M%S%N"))

;; Adapted From: https://emacsredux.com/blog/2019/01/10/convert-a-keyword-to-a-symbol/
;;;###autoload
(defun meq/keyword-to-symbol-name (keyword) (interactive)
  "Convert KEYWORD to symbol."
  (substring (symbol-name keyword) 1))

;; Adapted From:
;; Answer: https://stackoverflow.com/a/10088995/10827766
;; User: https://stackoverflow.com/users/324105/phils
;;;###autoload
(defun meq/fbatp (mode) (interactive)
    (let* ((is-it-bound (boundp mode)))
        (when is-it-bound (and
            (eval `(bound-and-true-p ,mode))
            ;; (or (fboundp mode) (functionp mode))
            ) mode)))

;; Adapted From:
;; Answer: https://emacs.stackexchange.com/a/26840/31428
;; User: https://emacs.stackexchange.com/users/253/dan
;; Adapted From: https://emacsredux.com/blog/2020/06/14/checking-the-major-mode-in-emacs-lisp/
;;;###autoload
(defun meq/outline-folded-p nil
    (with-eval-after-load 'org
        "Returns non-nil if point is on a folded headline or plain list
        item."
        (interactive)
        (and (if (eq major-mode 'org-mode)
                (or (org-at-heading-p)
                    (org-at-item-p))
                outline-on-heading-p)
            (invisible-p (point-at-eol))))

;; Adapted From:
;; Answer: https://emacs.stackexchange.com/a/37791/31428
;; User: https://emacs.stackexchange.com/users/12497/toothrot
;;;###autoload
(defun meq/go-to-parent nil (interactive)
    (with-eval-after-load 'org
        (outline-up-heading (if (and (or (org-at-heading-p) (invisible-p (point))) (invisible-p (point-at-eol))
                (>= (org-current-level) 2))
            1 0))))
;;;###autoload
(with-eval-after-load 'evil (advice-add #'evil-close-fold :before #'meq/go-to-parent))
;;;###autoload
(with-eval-after-load 'aiern (advice-add #'aiern-close-fold :before #'meq/go-to-parent))

;; Adapted From: https://www.reddit.com/r/emacs/comments/6klewl/org_cyclingto_go_from_folded_to_children_skipping/djniygy?utm_source=share&utm_medium=web2x&context=3
;;;###autoload
(defun meq/org-cycle nil (interactive)
    (with-eval-after-load 'org (if (meq/outline-folded-p) (org-cycle) (evil-close-fold))))

;; Adapted From:
;; Answer: https://emacs.stackexchange.com/questions/28098/how-to-change-org-mode-babel-tangle-write-to-file-way-as-append-instead-of-overr/38898#38898
;; User: https://emacs.stackexchange.com/users/2370/tobias
;;;###autoload
(defun meq/org-babel-tangle-append nil
    "Append source code block at point to its tangle file.
    The command works like `org-babel-tangle' with prefix arg
    but `delete-file' is ignored."
    (interactive)
    (with-eval-after-load 'org 
        (cl-letf (((symbol-function 'delete-file) #'ignore))
            (org-babel-tangle '(4)))))

;; Adapted From:
;; Answer: https://emacs.stackexchange.com/questions/28098/how-to-change-org-mode-babel-tangle-write-to-file-way-as-append-instead-of-overr/38898#38898
;; User: https://emacs.stackexchange.com/users/2370/tobias
;;;###autoload
(defun meq/org-babel-tangle-append-setup nil
    "Add key-binding C-c C-v C-t for `meq/org-babel-tangle-append'."
    (with-eval-after-load 'org (org-defkey org-mode-map (naked "C-c C-v +") 'meq/org-babel-tangle-append)))

;; Adapted From:
;; Answer: https://emacs.stackexchange.com/questions/39032/tangle-the-same-src-block-to-different-files/39039#39039
;; User: https://emacs.stackexchange.com/users/2370/tobias
;;;###autoload
(defun meq/org-babel-tangle-collect-blocks-handle-tangle-list (&optional language tangle-file)
    "Can be used as :override advice for `org-babel-tangle-collect-blocks'.
    Handles lists of :tangle files."
    (with-eval-after-load 'org
        (let ((counter 0) last-heading-pos blocks)
            (org-babel-map-src-blocks (buffer-file-name)
            (let ((current-heading-pos
                (org-with-wide-buffer
                (org-with-limited-levels (outline-previous-heading)))))
            (if (eq last-heading-pos current-heading-pos) (cl-incf counter)
            (setq counter 1)
            (setq last-heading-pos current-heading-pos)))
            (unless (org-in-commented-heading-p)
            (let* ((info (org-babel-get-src-block-info 'light))
                (src-lang (nth 0 info))
                (src-tfiles (cdr (assq :tangle (nth 2 info))))) ; Tobias: accept list for :tangle
            (unless (consp src-tfiles) ; Tobias: unify handling of strings and lists for :tangle
                (setq src-tfiles (list src-tfiles))) ; Tobias: unify handling
            (dolist (src-tfile src-tfiles) ; Tobias: iterate over list
                (unless (or (string= src-tfile "no")
                    (and tangle-file (not (equal tangle-file src-tfile)))
                    (and language (not (string= language src-lang))))
                ;; Add the spec for this block to blocks under its
                ;; language.
                (let ((by-lang (assoc src-lang blocks))
                    (block (org-babel-tangle-single-block counter)))
                (setcdr (assoc :tangle (nth 4 block)) src-tfile) ; Tobias: 
                (if by-lang (setcdr by-lang (cons block (cdr by-lang)))
                (push (cons src-lang (list block)) blocks)))))))) ; Tobias: just ()
            ;; Ensure blocks are in the correct order.
            (mapcar (lambda (b) (cons (car b) (nreverse (cdr b)))) blocks))))

;; Adapted From:
;; Answer: https://emacs.stackexchange.com/questions/39032/tangle-the-same-src-block-to-different-files/39039#39039
;; User: https://emacs.stackexchange.com/users/2370/tobias
;;;###autoload
(defun meq/org-babel-tangle-single-block-handle-tangle-list (oldfun block-counter &optional only-this-block)
    "Can be used as :around advice for `org-babel-tangle-single-block'.
    If the :tangle header arg is a list of files. Handle all files"
    (with-eval-after-load 'org
        (let* ((info (org-babel-get-src-block-info))
            (params (nth 2 info))
            (tfiles (cdr (assoc :tangle params))))
            (if (null (and only-this-block (consp tfiles)))
            (funcall oldfun block-counter only-this-block)
            (cl-assert (listp tfiles) nil
                ":tangle only allows a tangle file name or a list of tangle file names")
            (let ((ret (mapcar
                (lambda (tfile)
                    (let (old-get-info)
                    (cl-letf* (((symbol-function 'old-get-info) (symbol-function 'org-babel-get-src-block-info))
                        ((symbol-function 'org-babel-get-src-block-info)
                        `(lambda (&rest get-info-args)
                            (let* ((info (apply 'old-get-info get-info-args))
                                (params (nth 2 info))
                                (tfile-cons (assoc :tangle params)))
                            (setcdr tfile-cons ,tfile)
                            info))))
                    (funcall oldfun block-counter only-this-block))))
                tfiles)))
            (if only-this-block
                (list (cons (cl-caaar ret) (mapcar #'cadar ret)))
            ret))))))

;;;###autoload
(defun meq/src-mode-settings nil (interactive)
    (with-eval-after-load 'org (meq/disable-all-modal-modes) (when (featurep 'focus) (focus-mode 1))))
;;;###autoload
(defun meq/src-mode-exit nil (interactive)
    (with-eval-after-load 'org (when (featurep 'winner-mode) (winner-undo)) (meq/disable-all-modal-modes)))

;; Adapted From: https://github.com/syl20bnr/spacemacs/issues/13058#issuecomment-565741009
;;;###autoload
(advice-add #'org-edit-src-exit :after #'meq/src-mode-exit)
;;;###autoload
(advice-add #'org-edit-src-abort :after #'meq/src-mode-exit)
;;;###autoload
(advice-add #'org-edit-special :after #'meq/src-mode-settings)
;;;###autoload
(advice-add #'org-babel-tangle-collect-blocks :override #'meq/org-babel-tangle-collect-blocks-handle-tangle-list)
;;;###autoload
(advice-add #'org-babel-tangle-single-block :around #'meq/org-babel-tangle-single-block-handle-tangle-list)
;;;###autoload
(add-hook 'org-mode-hook 'meq/org-babel-tangle-append-setup)
;;;###autoload
(add-hook 'org-cycle-hook '(lambda (state) (interactive) (when (eq state 'children) (setq org-cycle-subtree-status 'subtree))))

;; Adapted From: http://endlessparentheses.com/emacs-narrow-or-widen-dwim.html
;;;###autoload
(defun meq/narrow-or-widen-dwim (p)
    "Widen if buffer is narrowed, narrow-dwim otherwise.
    Dwim means: region, org-src-block, org-subtree, or
    defun, whichever applies first. Narrowing to
    org-src-block actually calls `org-edit-src-code'.

    With prefix P, don't widen, just narrow even if buffer
    is already narrowed."
    (interactive "P")
    (with-eval-after-load 'org
        (declare (interactive-only))
        (cond ((and (buffer-narrowed-p) (not p)) (widen))
                ((region-active-p)
                (narrow-to-region (region-beginning)
                                (region-end)))
                ((derived-mode-p 'org-mode)
                ;; `org-edit-src-code' is not a real narrowing
                ;; command. Remove this first conditional if
                ;; you don't want it.
                (cond ((ignore-errors (org-edit-src-code) t)
                        (delete-other-windows))
                    ((ignore-errors (org-narrow-to-block) t))
                    (t (org-narrow-to-subtree))))
                ((derived-mode-p 'latex-mode)
                (LaTeX-narrow-to-environment))
                (t (narrow-to-defun)))
            (meq/src-mode-settings))))

;; Adapted From:
;; Answer: https://emacs.stackexchange.com/a/42240
;; User: user12563
;;;###autoload
(defun meq/disable-all-modal-modes (&optional keymap include-ignored) (interactive)
    (mapc
        #'(lambda (mode-symbol)
            ;; some symbols are functions which aren't normal mode functions
            (when (and
                    (meq/fbatp mode-symbol)
                    (not (member mode-symbol meq/var/ignored-modal-modes)))
                (message (format "Disabling %s" (symbol-name mode-symbol)))
                (ignore-errors
                    (funcall mode-symbol -1))))
            meq/var/modal-modes)
    (mapc
        #'(lambda (mode-symbol)
            ;; some symbols are functions which aren't normal mode functions
            (when (meq/fbatp mode-symbol)
                (if include-ignored
                    (progn (message (format "Disabling %s" (symbol-name mode-symbol)))
                    (ignore-errors (funcall mode-symbol -1)))
                    (message (format "Enabling %s" (symbol-name mode-symbol)))
                    (ignore-errors (funcall mode-symbol 1)))))
            meq/var/ignored-modal-modes)
    (when include-ignored (setq meq/var/all-modal-modes-off t))
    (cosmoem-hide-all-modal-modes keymap include-ignored))

;; Answer: https://stackoverflow.com/a/14490054/10827766
;; User: https://stackoverflow.com/users/1600898/user4815162342
;;;###autoload
(defun meq/keymap-symbol (keymap)
    "Return the symbol to which KEYMAP is bound, or nil if no such symbol exists."
    (interactive)
    (catch 'gotit
        (mapatoms (lambda (sym)
            (and (boundp sym)
                (eq (symbol-value sym) keymap)
                (not (eq sym 'keymap))
                (throw 'gotit sym))))))

;; Adapted From:
;; Answer: https://superuser.com/a/331662/1154755
;; User: https://superuser.com/users/656734/phimuemue
;;;###autoload
(defun meq/end-of-line-and-indented-new-line nil (interactive) (end-of-line) (newline-and-indent))

;; Adapted From:
;; Answer: https://emacs.stackexchange.com/questions/12997/how-do-i-use-nadvice/14827#14827
;; User: https://emacs.stackexchange.com/users/2308/kdb
;;;###autoload
(defun meq/which-key--hide-popup (&optional force dont-disable-modal-modes) (interactive)
        (when force (setq meq/var/which-key-really-dont-show t))
        (unless dont-disable-modal-modes (meq/disable-all-modal-modes))
        (setq which-key-persistent-popup nil)
        (which-key--hide-popup)
        (which-key-mode -1))

;;;###autoload
(defun meq/which-key--show-popup (&optional keymap force disable-modal-modes) (interactive)
    (let ((show-popup #'(lambda (keymap) (interactive)
            (which-key-mode 1)
            (setq which-key-persistent-popup t)
            (if disable-modal-modes
                (meq/disable-all-modal-modes keymap)
                (meq/which-key-show-top-level keymap)))))
        (if meq/var/which-key-really-dont-show
            (when force (setq meq/var/which-key-really-dont-show nil) (funcall show-popup keymap))
            (funcall show-popup keymap))))

;;;###autoload
(with-eval-after-load 'aiern (mapc #'(lambda (state) (interactive)
    (add-hook (intern (concat "aiern-" (symbol-name (car state)) "-state-entry-hook"))
        #'(lambda nil (interactive)
            (meq/which-key--show-popup (intern (concat "aiern-" (symbol-name (car state)) "-state-map")))))
    (add-hook (intern (concat "aiern-" (symbol-name (car state)) "-state-exit-hook"))
        #'(lambda nil (interactive)
            (meq/which-key--show-popup)))
    (add-hook (intern (concat "evil-" (symbol-name (car state)) "-state-entry-hook"))
        #'(lambda nil (interactive)
            (meq/which-key--show-popup (intern (concat "evil-" (symbol-name (car state)) "-state-map")))))
    (add-hook (intern (concat "evil-" (symbol-name (car state)) "-state-exit-hook"))
        #'(lambda nil (interactive)
            (meq/which-key--show-popup))))
    aiern-state-properties))

;;;###autoload
(defun meq/which-key--refresh-popup (&optional keymap) (interactive)
    (meq/which-key--hide-popup t)
    (meq/which-key--show-popup keymap t))

;;;###autoload
(defun meq/toggle-which-key (&optional keymap) (interactive)
    (if (any-popup-showing-p)
        (meq/which-key--hide-popup t)
        (meq/which-key--show-popup keymap t)
        ;; (meq/which-key-show-top-level keymap)
        ))

;;;###autoload
(defun meq/which-key-show-top-level (&optional keymap) (interactive)
    (let* ((current-map (or (symbol-value keymap) (or overriding-terminal-local-map global-map)))
        (which-key-function
            ;; #'which-key-show-top-level
            ;; #'(lambda nil (interactive) (which-key-show-full-keymap 'global-map))
            ;; #'which-key-show-full-major-mode
            ;; #'which-key-show-major-mode

            ;; Adapted From:
            ;; https://github.com/justbur/emacs-which-key/blob/master/which-key.el#L2359
            ;; https://github.com/justbur/emacs-which-key/blob/master/which-key.el#L2666
            #'(lambda nil (interactive)
                (when which-key-persistent-popup (which-key--create-buffer-and-show nil current-map nil "Current bindings")))))
        (if (which-key--popup-showing-p)
            (when keymap (funcall which-key-function))
            (funcall which-key-function))))

;; Adapted From:
;; Answer: https://emacs.stackexchange.com/a/14956/31428
;; User: https://emacs.stackexchange.com/users/25/gilles-so-stop-being-evil
;; (with-eval-after-load 'evil (defun meq/newline-and-indent-advice (func &rest arguments)
;;;###autoload
(defun meq/newline-and-indent-advice (func &rest arguments)
    (if (window-minibuffer-p)
        (cond
            ((evil-ex-p) (evil-ex-execute (minibuffer-contents)))
            ((aiern-ex-p) (aiern-ex-execute (minibuffer-contents)))
            (t (progn (minibuffer-complete-and-exit) (minibuffer-complete-and-exit))))
        (apply func arguments)))
        ;; )

;;;###autoload
(defun meq/current-modal-modes (&optional include-ignored) (interactive)
    (-filter #'(lambda (mode) (interactive) (eval `(bound-and-true-p ,mode)))
        (append (when include-ignored meq/var/ignored-modal-modes) meq/var/modal-modes)))

;;;###autoload
(defun meq/pre-post-command-hook-command nil (interactive)
    ;; (if (window-minibuffer-p)
    (if (or (derived-mode-p 'prog-mode)
            (derived-mode-p 'text-mode))
        (alloy-def :keymaps 'override "RET" 'newline-and-indent)
        (alloy-def :keymaps 'override "RET" nil))
    (if (derived-mode-p 'vterm-mode)
        (unless meq/var/all-modal-modes-off (setq meq/var/backup-modal-modes (meq/current-modal-modes t)
                meq/var/backup-terminal-local-map overriding-terminal-local-map
                overriding-terminal-local-map vterm-mode-map)
            (meq/disable-all-modal-modes nil t))
        (when meq/var/all-modal-modes-off (mapc #'(lambda (mode) (interactive)
            (when (meq/fbatp mode) (ignore-errors (funcall mode 1)))) meq/var/backup-modal-modes)
            (setq meq/var/backup-modal-modes nil
                meq/var/all-modal-modes-off nil
                overriding-terminal-local-map meq/var/backup-terminal-local-map))))
;;;###autoload
(add-hook 'pre-command-hook 'meq/pre-post-command-hook-command)
;;;###autoload
(add-hook 'post-command-hook 'meq/pre-post-command-hook-command)

;;;###autoload
(defun meq/evil-ex-advice (func &rest arguments)
    (meq/which-key--hide-popup nil t)
    (setq meq/var/last-global-map (current-global-map))
    (use-global-map global-map)

    (apply func arguments)

    (use-global-map meq/var/last-global-map)
    (setq meq/var/last-global-map nil)
    (meq/which-key--show-popup))
;;;###autoload
(with-eval-after-load 'aiern (advice-add #'aiern-ex :around #'meq/evil-ex-advice))
;;;###autoload
(with-eval-after-load 'evil (advice-add #'evil-ex :around #'meq/evil-ex-advice))

;; From: https://github.com/hlissner/doom-emacs/blob/develop/core/core-keybinds.el#L83
;;;###autoload
(defun meq/doom/escape (&optional interactive)
  "Run `doom-escape-hook'."
  (interactive (list 'interactive))
  (cond ((minibuffer-window-active-p (minibuffer-window))
         ;; quit the minibuffer if open.
         (when interactive
           (setq this-command 'abort-recursive-edit))
         (abort-recursive-edit))
        ;; Run all escape hooks. If any returns non-nil, then stop there.
        ((run-hook-with-args-until-success 'doom-escape-hook))
        ;; don't abort macros
        ((or defining-kbd-macro executing-kbd-macro) nil)
        ;; Back to the default

        ;; TODO: Incorporate deino-keyboard-quit and hydra-keyboard-quit here
        ((unwind-protect (keyboard-escape-quit)
           (when interactive
             (setq this-command 'keyboard-escape-quit))))))
;;;###autoload
(advice-add #'keyboard-quit :override #'meq/doom/escape)

;;;###autoload
(defun meq/M-x nil (interactive) (if (window-minibuffer-p) (meq/doom/escape) (execute-extended-command nil)))

;; From:
;; Answer: https://stackoverflow.com/questions/24832699/emacs-24-untabify-on-save-for-everything-except-makefiles
;; User: https://stackoverflow.com/users/2677392/ryan-m
;;;###autoload
(defun meq/untabify-everything nil (untabify (point-min) (point-max)))

;; Adapted From:
;; Answer: https://stackoverflow.com/a/24857101/10827766
;; User: https://stackoverflow.com/users/936762/dan
;;;###autoload
(defun meq/untabify-except-makefiles nil
  "Replace tabs with spaces except in makefiles."
  (unless (derived-mode-p 'makefile-mode)
    (meq/untabify-everything)))
;;;###autoload
(add-hook 'before-save-hook 'meq/untabify-except-makefiles)

;; Adapted From: https://github.com/emacsorphanage/god-mode/blob/master/god-mode.el#L454
;;;###autoload
(defun meq/god-prefix-command-p nil
  "Return non-nil if the current command is a \"prefix\" command.
This includes prefix arguments and any other command that should
be ignored by `god-execute-with-current-bindings'."
  (memq this-command '((when (featurep 'god-mode) god-mode-self-insert)
                       digit-argument
                       negative-argument
                       universal-argument
                       universal-argument-more)))

;;;###autoload
(defun meq/hydra-force-disable nil
    "Disable the current Hydra."
    (interactive)
    (with-eval-after-load 'hydra
        (setq hydra-deactivate nil)
        (remove-hook 'pre-command-hook 'hydra--clearfun)
        (if (fboundp 'remove-function)
                (remove-function input-method-function #'hydra--imf)
                (when hydra--input-method-function
                    (setq input-method-function hydra--input-method-function)
                    (setq hydra--input-method-function nil))))
        (dolist (frame (frame-list))
            (with-selected-frame frame
            (when overriding-terminal-local-map
                (internal-pop-keymap hydra-curr-map 'overriding-terminal-local-map))))
        (setq hydra-curr-map nil)
        (when hydra-curr-on-exit
            (let ((on-exit hydra-curr-on-exit))
            (setq hydra-curr-on-exit nil)
            (funcall on-exit))))

;; Adapted From:
;; Answer: https://stackoverflow.com/questions/2580650/how-can-i-reload-emacs-after-changing-it/51781491#51781491
;; User: user4104817
;;;###autoload
(defun meq/reload-emacs nil (interactive)
    (load (concat user-emacs-directory "early-init.el"))
    (load (concat user-emacs-directory "init.el")))

;; Adapted From: http://whattheemacsd.com/file-defuns.el-01.html
(defun meq/rename-current-buffer-file (&optional new-name*)
  "Renames current buffer and file it is visiting."
  (interactive)
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (error "Buffer '%s' is not visiting a file!" name)
      (let ((new-name (or new-name* (read-file-name "New name: " filename))))
        (if (get-buffer new-name)
            (error "A buffer named '%s' already exists!" new-name)
          (rename-file filename new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil)
          (message "File '%s' successfully renamed to '%s'"
                   name (file-name-nondirectory new-name)))))))

;; Adapted From: http://whattheemacsd.com/file-defuns.el-02.html
(defun meq/delete-current-buffer-file nil
  "Removes file connected to current buffer and kills buffer."
  (interactive)
  (let ((filename (buffer-file-name))
        (buffer (current-buffer))
        (name (buffer-name)))
    (if (not (and filename (file-regular-p filename)))
        (ido-kill-buffer)
      (when (y-or-n-p "Are you sure you want to remove this file? ")
        (delete-file filename)
        (kill-buffer buffer)
        (message "File '%s' successfully removed" filename)))))

;; Adapted From:
;; Answer: https://emacs.stackexchange.com/a/14861/31428
;; User: user227
(defun meq/substring (substring string) (string-match-p (regexp-quote substring) string))

;;;###autoload
(with-eval-after-load 'aiern (with-eval-after-load 'evil (defun meq/both-ex-define-cmd (cmd function) (interactive)
    (evil-ex-define-cmd cmd function)
    (aiern-ex-define-cmd cmd function))))

;;;###autoload
(with-eval-after-load 'counsel (advice-add #'counsel-M-x :before #'meq/which-key--hide-popup))
;;;###autoload
(with-eval-after-load 'helm
    (advice-add #'helm-smex-major-mode-commands :before #'meq/which-key--hide-popup)
    (advice-add #'helm-smex :before #'meq/which-key--hide-popup))

;; TODO
;; ;;;###autoload
;; (advice-add #'execute-extended-command :before #'meq/which-key--hide-popup)

;;;###autoload
(advice-add #'keyboard-escape-quit :after #'meq/which-key--show-popup)
;;;###autoload
(advice-add #'keyboard-quit :after #'meq/which-key--show-popup)
;;;###autoload
(advice-add #'exit-minibuffer :after #'meq/which-key--show-popup)

;;;###autoload
(add-hook 'after-init-hook 'key-chord-mode)

(provide 'meq)
;;; meq.el ends here
