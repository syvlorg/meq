;;; meq.el --- a simple package                     -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Jeet Ray

;; Author: Jeet Ray <aiern@protonmail.com>
;; Keywords: lisp
;; Version: 0.0.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU alloy Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU alloy Public License for more details.

;; You should have received a copy of the GNU alloy Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; 

;;; Code:

(require 'naked)
(require 'thingatpt)
(require 'f)
(require 's)
(require 'dash)
(require 'key-chord)
(require 'uuidgen)

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
(defvar meq/var/last-buffer nil)
(defvar meq/var/which-key-first-show t)
(defvar meq/var/tab-size-in-spaces 4)

;;;###autoload
(defun meq/ued (&rest args) (f-full (apply #'f-join user-emacs-directory args)))
;;;###autoload
(defun meq/ued-lib (&rest args) (f-full (apply #'meq/ued "lib" args)))
;;;###autoload
(defun meq/ued-siluam (&rest args) (f-full (apply #'meq/ued "siluam" args)))
;;;###autoload
(defun meq/ued-profiles (&rest args) (f-full (apply #'meq/ued "profiles" args)))
;;;###autoload
(defun meq/ued-settings (&rest args) (f-full (apply #'meq/ued "settings" args)))
;;;###autoload
(defun meq/ued-local (&rest args) (f-full (apply #'meq/ued ".local" args)))
;;;###autoload
(defun meq/cl (&rest args)
    (let* ((path (if (f-exists? (car args)) (car args) (apply #'meq/ued args)))
            (path-exists (f-exists? path))
            (org-file* (when path-exists (f-ext path)))
            (org-file (and org-file* (string= org-file* "org"))))
        (when path-exists
            (if org-file (org-babel-load-file path t) (load path)))))

;;;###autoload
(defun meq/load-emacs-file (&rest files) (mapc #'(lambda (file) (interactive) (load (meq/ued-lib file))) files))

;;;###autoload
(defun meq/load-siluam-file (&rest files) (mapc #'(lambda (file) (interactive) (load (meq/ued-siluam file))) files))

;;;###autoload
(defun meq/timestamp nil (interactive) (format-time-string "%Y%m%d%H%M%S%N"))

;;;###autoload
(defun meq/uuid (&rest args) (interactive) (apply (intern (concat "uuidgen-" (or (car args) "5")))
                                                  (or (cdr args) (list (uuidgen-4) (uuidgen-4)))))

;;;###autoload
(defun meq/named-uuid (name) (interactive) (meq/uuid "5" (meq/uuid) name))

;;;###autoload
(defun meq/pget (item plist) (or (ignore-error (plist-get plist item)) (cl-getf plist item)))

;;;###autoload
(defun meq/basename (&optional file) (interactive) (car (split-string (file-name-base (or file buffer-file-name)) "\\.")))

;; Adapted From: https://emacsredux.com/blog/2019/01/10/convert-a-keyword-to-a-symbol/
;;;###autoload
(defun meq/keyword-to-symbol-name (keyword) (interactive)
  "Convert KEYWORD to symbol."
  (substring (symbol-name keyword) 1))

;;;###autoload
(defun meq/inconcat (&rest strings) (intern (apply #'concat strings)))

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

;;;###autoload
(defun meq/ncp nil (interactive) (and (meq/fbatp 'native-comp-available-p) (native-comp-available-p)))

;;;###autoload
(defun meq/listtp (list*) (interactive) (and list* (or (consp list*) (listp list*))))

;; Adapted From: https://www.reddit.com/r/emacs/comments/ahcmi7/exwm_variable_to_detect_if_it_is_being_used/eedfhs0?utm_source=share&utm_medium=web2x&context=3
;;;###autoload
(defun meq/exwm-p nil (interactive) (when (featurep 'exwm) (frame-parameter (selected-frame) 'exwm-active)))

;;;###autoload
(defun meq/xwinp nil (interactive) (when (featurep 'exwm) (derived-mode-p 'exwm-mode)))

;;;###autoload
(defun meq/windows-p nil (interactive) (member system-type '(windows-nt ms-dos)))

;; Adapted From: https://kitchingroup.cheme.cmu.edu/blog/2015/03/19/Restarting-org-babel-sessions-in-org-mode-more-effectively/
;;;###autoload
(defun meq/org-babel-restart-session-to-point (&optional arg)
  "Restart session up to the src-block in the current point.
Goes to beginning of buffer and executes each code block with
`org-babel-execute-src-block' that has the same language and
session as the current block. ARG has same meaning as in
`org-babel-execute-src-block'."
  (interactive "P")
  (when (and (featurep 'org) (not (org-in-src-block-p)))
    (error "You must be in a src-block to run this command"))
  (let* ((current-point (point-marker))
         (info (org-babel-get-src-block-info))
         (lang (nth 0 info))
         (params (nth 2 info))
         (session (cdr (assoc :session params))))
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward org-babel-src-block-regexp nil t)
        ;; goto start of block
        (goto-char (match-beginning 0))
        (let* ((this-info (org-babel-get-src-block-info))
               (this-lang (nth 0 this-info))
               (this-params (nth 2 this-info))
               (this-session (cdr (assoc :session this-params))))
            (when
                (and
                 (< (point) (marker-position current-point))
                 (string= lang this-lang)
                 (src-block-in-session-p session))
              (org-babel-execute-src-block arg)))
        ;; move forward so we can find the next block
        (forward-line)))))

;; Adapted From: https://kitchingroup.cheme.cmu.edu/blog/2015/03/19/Restarting-org-babel-sessions-in-org-mode-more-effectively/
;;;###autoload
(defun meq/org-babel-kill-session nil
  "Kill session for current code block."
  (interactive)
  (when (and (featurep 'org) (not (org-in-src-block-p)))
    (error "You must be in a src-block to run this command"))
  (save-window-excursion
    (org-babel-switch-to-session)
    (kill-buffer)))

;; Adapted From: https://kitchingroup.cheme.cmu.edu/blog/2015/03/19/Restarting-org-babel-sessions-in-org-mode-more-effectively/
;;;###autoload
(defun meq/org-babel-remove-result-buffer nil
  "Remove results from every code block in buffer."
  (interactive)
  (when (featurep 'org)
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward org-babel-src-block-regexp nil t)
        (org-babel-remove-result)))))

;; Adapted From:
;; Answer: https://emacs.stackexchange.com/a/26840/31428
;; User: https://emacs.stackexchange.com/users/253/dan
;; And: https://emacsredux.com/blog/2020/06/14/checking-the-major-mode-in-emacs-lisp/
;;;###autoload
(defun meq/outline-on-heading-p nil
    "Returns non-nil if point is on a headline."
    (interactive)
    (if (derived-mode-p 'org-mode)
        (or (outline-on-heading-p)

            ;; From: https://github.com/bzg/org-mode/blob/edddc7d149b8668a830443b12db14075beb28607/lisp/org.el#L20744
            (org-at-heading-p))

        (outline-on-heading-p)))

;; From: https://github.com/bzg/org-mode/blob/edddc7d149b8668a830443b12db14075beb28607/lisp/org.el#L12889            
(unless (fboundp 'org-at-property-drawer-p)
    (defun org-at-property-drawer-p ()
  "Non-nil when point is at the first line of a property drawer."
  (org-with-wide-buffer
   (beginning-of-line)
   (and (looking-at org-property-drawer-re)
	(or (bobp)
	    (progn
	      (forward-line -1)
	      (cond ((org-at-heading-p))
		    ((looking-at org-planning-line-re)
		     (forward-line -1)
		     (org-at-heading-p))
		    ((looking-at org-comment-regexp)
		     (forward-line -1)
		     (while (and (not (bobp)) (looking-at org-comment-regexp))
		       (forward-line -1))
		     (looking-at org-comment-regexp))
		    (t nil))))))))

;; Adapted From:
;; Answer: https://emacs.stackexchange.com/a/26840/31428
;; User: https://emacs.stackexchange.com/users/253/dan
;; And: https://emacsredux.com/blog/2020/06/14/checking-the-major-mode-in-emacs-lisp/
;;;###autoload
(defun meq/foldable-p nil
    "Returns non-nil if point can fold."
    (interactive)
    (or (meq/outline-on-heading-p)

        (when (derived-mode-p 'org-mode) (or (org-at-property-drawer-p)

            ;; From: https://github.com/bzg/org-mode/blob/edddc7d149b8668a830443b12db14075beb28607/lisp/org.el#L20809
            (org-at-drawer-p)

            ;; From: https://github.com/bzg/org-mode/blob/edddc7d149b8668a830443b12db14075beb28607/lisp/org.el#L20815
            (org-at-block-p)))

        (invisible-p (point-at-eol))))

;; Adapted From: https://github.com/bzg/org-mode/blob/main/lisp/org-id.el#L275
;;;###autoload
(defun meq/org-custom-id-get (&optional pom create prefix)
  "Get the CUSTOM_ID property of the entry at point-or-marker POM.
If POM is nil, refer to the entry at point.
If the entry does not have an CUSTOM_ID, the function returns nil.
However, when CREATE is non-nil, create an CUSTOM_ID if none is present already.
PREFIX will be passed through to `org-id-new'.
In any case, the CUSTOM_ID of the entry is returned."
  (org-with-point-at pom
    (let ((custom-id (org-entry-get nil "CUSTOM_ID")))
      (cond
       ((and custom-id (stringp custom-id) (string-match "\\S-" custom-id))
	custom-id)
       (create
	(setq custom-id (org-id-new prefix))
	(org-entry-put pom "CUSTOM_ID" custom-id)
	custom-id)))))

;; Adapted From: https://github.com/bzg/org-mode/blob/main/lisp/org-id.el#L253
;;;###autoload
(defun meq/org-custom-id-get-create (&optional force)
  "Create an CUSTOM_ID for the current entry and return it.
If the entry already has an CUSTOM_ID, just return it.
With optional argument FORCE, force the creation of a new CUSTOM_ID."
  (interactive "P")
  (when force
    (org-entry-put (point) "CUSTOM_ID" nil))
  (meq/org-custom-id-get (point) 'create))

;;;###autoload
(defun meq/folded-p nil "Returns non-nil if point is on a folded org object." (interactive) (and (meq/foldable-p) (invisible-p (point-at-eol))))

;;;###autoload
(defun meq/unfolded-p nil "Returns non-nil if point is on an unfolded org object." (interactive) (and (meq/foldable-p) (not (invisible-p (point-at-eol)))))

;; Adapted From:
;; Answer: https://emacs.stackexchange.com/a/37791/31428
;; User: https://emacs.stackexchange.com/users/12497/toothrot
;;;###autoload
(defun meq/go-to-parent (&optional steps) (interactive) (ignore-error (outline-up-heading (or steps 0))))

;; Adapted From:
;; Answer: https://stackoverflow.com/a/27799515
;; User: https://stackoverflow.com/users/850781/sds
;;;###autoload
(defun meq/prior-char (&optional *point) (interactive) (char-syntax (if *point (char-before *point) (preceding-char))))

;;;###autoload
(defun meq/whitespace-before-p (&optional *point) (interactive) (member (meq/prior-char *point) `(,(string-to-char " ") ,(string-to-char "\t"))))

;;;###autoload
(defun meq/newline-p (&optional *point) (interactive) (member (meq/prior-char *point) `(,(string-to-char "\n"))))

;;;###autoload
(defun meq/delete-while-white (&optional *not) (interactive) (while (if *not (not (meq/whitespace-before-p)) (meq/whitespace-before-p)) (delete-backward-char 1)))

;;;###autoload
(defun meq/delete-white-or-word nil (interactive) (cond
    ((bolp) (delete-backward-char 1))
    ((meq/whitespace-before-p) (if (meq/whitespace-before-p (1- (point)))
                        (meq/delete-while-white)
                        (delete-backward-char 1)
                        (meq/delete-while-white t)))
    (t (meq/delete-while-white t))))

;;;###autoload
(defun meq/outline-cycle (func &rest args) (interactive) (if (meq/folded-p)
    (progn
        ;; (when (invisible-p (point)) (beginning-of-line) (when (invisible-p (point)) (while (invisible-p (point)) (backward-char))))

        ;; Adapted From: https://www.reddit.com/r/emacs/comments/rlxkjn/move_cursor_from_invisible_region_to_visible/
        (when (invisible-p (point)) (while (invisible-p (1- (point))) (goto-char (previous-single-char-property-change (point) 'invisible))))
        
        (apply func args))
    (if (meq/outline-on-heading-p)
        (cond
            ((meq/fbatp aiern-mode) (aiern-close-fold))
            ((meq/fbatp evil-mode) (evil-close-fold))
            (t (outline-hide-subtree)))
        (cond
            ((meq/fbatp aiern-mode) (if (meq/foldable-p) (apply func args) (meq/go-to-parent) (aiern-close-fold)))
            ((meq/fbatp evil-mode) (if (meq/foldable-p) (apply func args) (meq/go-to-parent) (evil-close-fold)))
            (t (apply func args))))
    (message "FOLDED")))

;; Adapted From:
;; Answer: https://emacs.stackexchange.com/a/54550
;; User: https://emacs.stackexchange.com/users/21533/jagrg
;;;###autoload
(defun meq/tab (&optional tab-size-in-spaces) (insert (make-string (or tab-size-in-spaces meq/var/tab-size-in-spaces) ?\s)))

;;;###autoload
(defun meq/untab (&optional tab-size-in-spaces) (interactive) (mapc
    #'(lambda (i) (interactive) (when (meq/whitespace-before-p) (delete-backward-char 1)))
    (number-sequence 1 (or tab-size-in-spaces meq/var/tab-size-in-spaces))))

;;;###autoload
(defun meq/outline-indent (untab) (interactive) (if untab (meq/untab) (meq/tab)))

;;;###autoload
(defun meq/outline-cycle-indent (untab func &rest args) (interactive)
    (let* ((oci (lambda (untab func &rest args) (interactive) (if (meq/foldable-p) (apply #'meq/outline-cycle func args) (meq/outline-indent untab)))))
        (cond
            ((meq/fbatp aiern-mode) (cond
                ((member aiern-state '(normal visual)) (apply #'meq/outline-cycle func args))
                ((member aiern-state '(insert)) (meq/outline-indent untab))
                (t (apply oci untab func args))))
            ((meq/fbatp evil-mode) (cond
                ((member evil-state '(normal visual)) (apply #'meq/outline-cycle func args))
                ((member evil-state '(insert)) (meq/outline-indent untab))
                (t (apply oci untab func args))))
            (t (apply oci untab func args)))))

;;;###autoload
(advice-add #'org-cycle :around #'(lambda (func &rest args) (interactive) (apply #'meq/outline-cycle-indent nil func args)))

;;;###autoload
(advice-add #'org-shifttab :around #'(lambda (func &rest args) (interactive) (apply #'meq/outline-cycle-indent t func args)))

;; Adapted From:
;; Answer: https://emacs.stackexchange.com/questions/28098/how-to-change-org-mode-babel-tangle-write-to-file-way-as-append-instead-of-overr/38898#38898
;; User: https://emacs.stackexchange.com/users/2370/tobias
;;;###autoload
(defun meq/org-babel-tangle-append nil
    "Append source code block at point to its tangle file.
    The command works like `org-babel-tangle' with prefix arg
    but `delete-file' is ignored."
    (interactive)
    (when (featurep 'org)
        (cl-letf (((symbol-function 'delete-file) #'ignore))
            (org-babel-tangle '(4)))))

;; Adapted From:
;; Answer: https://emacs.stackexchange.com/questions/39032/tangle-the-same-src-block-to-different-files/39039#39039
;; User: https://emacs.stackexchange.com/users/2370/tobias
;;;###autoload
(defun meq/org-babel-tangle-collect-blocks-handle-tangle-list (&optional language tangle-file)
    "Can be used as :override advice for `org-babel-tangle-collect-blocks'.
    Handles lists of :tangle files."
    (when (featurep 'org)
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
    (when (featurep 'org)
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
(defun meq/get-tangled-file-name (&optional file*) (interactive)
    (with-current-buffer (get-file-buffer (or file* buffer-file-name))

        ;; Adapted From:
        ;; Answer: https://emacs.stackexchange.com/a/24521/31428
        ;; User: https://emacs.stackexchange.com/users/12616/konstantin-morenko
        (goto-line 1)

        ;; Adapted From:
        ;; Answer: https://emacs.stackexchange.com/a/15136/31428
        ;; User: https://emacs.stackexchange.com/users/253/dan
        (let* ((line (thing-at-point 'line))

                (split-line (split-string line ":")))
            (f-full (cadr split-line)))))

;;;###autoload
(defun meq/org-babel-detangle-and-return (&optional file* origin*) (interactive)
    (when (featurep 'org)
        (save-current-buffer
            (let* ((file (or file* buffer-file-name))
                    (origin-buffer (get-file-buffer (or
                                        origin*
                                        (meq/get-tangled-file-name file)))))
                (org-babel-detangle file)
                (when origin-buffer
                    (set-buffer origin-buffer)
                    (save-buffer)
                    (kill-buffer origin-buffer))

                ;; Adapted From:
                ;; Answer: https://stackoverflow.com/a/44049569/10827766
                ;; User: https://stackoverflow.com/users/2876504/alejandro-c
                (delete-window (previous-window))))))

;;;###autoload
(defun meq/org-babel-detangle-kill-and-return (file &optional origin) (interactive)
    (let* ((file-buffer (get-file-buffer file)))
        (meq/org-babel-detangle-and-return file origin)
        (when file-buffer (kill-buffer file-buffer))))

;;;###autoload
(defun meq/generate-obdar (file &optional origin)
    (add-hook 'after-save-hook #'(lambda nil (interactive)
        (when (eq (get-file-buffer file) (current-buffer))
            (meq/org-babel-detangle-and-return file origin)))))

;;;###autoload
(defun meq/moff (mode) (if (meq/fbatp mode) 0 1))

;;;###autoload
(defun meq/after-init nil (interactive)
    (when (featurep 'writeroom-mode) (writeroom-mode (meq/moff writeroom-mode))))

;;;###autoload
(defun meq/src-mode-settings nil (interactive)
    (when (featurep 'org) (meq/disable-all-modal-modes) (meq/after-init)))
;;;###autoload
(defun meq/src-mode-exit nil (interactive) (when (featurep 'org) (meq/disable-all-modal-modes)))

;; Adapted From: https://github.com/syl20bnr/spacemacs/issues/13058#issuecomment-565741009
;; ;;;###autoload
;; (advice-add #'org-edit-src-exit :after #'meq/src-mode-exit)
;; ;;;###autoload
;; (advice-add #'org-edit-src-abort :after #'meq/src-mode-exit)
;;;###autoload
(advice-add #'org-edit-special :after #'meq/src-mode-settings)
;;;###autoload
(advice-add #'org-babel-tangle-collect-blocks :override #'meq/org-babel-tangle-collect-blocks-handle-tangle-list)
;;;###autoload
(advice-add #'org-babel-tangle-single-block :around #'meq/org-babel-tangle-single-block-handle-tangle-list)

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
    (when (featurep 'org)
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
            (meq/src-mode-settings)))

;;;###autoload
(defmacro meq/add-to-ignored-modal-modes (**mode &rest args) (interactive)
    (let* ((*mode (symbol-name **mode))
            (mode (meq/inconcat *mode "-mode")))
        (eval `(progn ,@args))
        (push mode meq/var/ignored-modal-modes)
        (push *mode meq/var/ignored-modal-prefixes)
        (funcall mode 1)))

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
                    (progn
                        (message (format "Disabling %s" (symbol-name mode-symbol)))
                        (ignore-errors (funcall mode-symbol -1)))
                    (message (format "Enabling %s" (symbol-name mode-symbol)))
                    (ignore-errors (funcall mode-symbol 1)))))
            meq/var/ignored-modal-modes)
    (when include-ignored (setq meq/var/all-modal-modes-off t))
    (when (featurep 'cosmoem) (cosmoem-hide-all-modal-modes keymap include-ignored)))

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
    (let* ((popup-was-up (which-key--popup-showing-p)))
        (when force (setq meq/var/which-key-really-dont-show t))
        (unless dont-disable-modal-modes (meq/disable-all-modal-modes))
        (setq which-key-persistent-popup nil)
        (which-key--hide-popup)
        (which-key-mode -1)
        (when meq/var/which-key-first-show
            ;; Adapted From:
            ;; Answer: https://stackoverflow.com/a/44049569/10827766
            ;; User: https://stackoverflow.com/users/2876504/alejandro-c
            (when popup-was-up (delete-window (previous-window)))

            (setq meq/var/which-key-first-show nil))))

;; Adapted From: https://www.reddit.com/r/emacs/comments/3u0d0u/how_do_i_make_the_vertical_window_divider_more/cxb78ul?utm_source=share&utm_medium=web2x&context=3
;; More Information Here: https://www.gnu.org/software/emacs/manual/html_node/elisp/Display-Tables.html
;;;###autoload
(defun meq/window-divider nil
  (let ((display-table (or buffer-display-table standard-display-table)))
    (when display-table (set-display-table-slot display-table 0 ? )
    (set-display-table-slot display-table 1 ? )
    (set-display-table-slot display-table 5 ? )
    (set-window-display-table (selected-window) display-table))))

;; ;;;###autoload
(add-hook 'window-configuration-change-hook #'meq/window-divider)

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
            (funcall show-popup keymap))
        (setq meq/var/all-keymaps-map nil)))

;;;###autoload
(with-eval-after-load 'aiern (mapc #'(lambda (state) (interactive)
    (add-hook (meq/inconcat "aiern-" (symbol-name (car state)) "-state-entry-hook")
        #'(lambda nil (interactive)
            (meq/which-key--show-popup (meq/inconcat "aiern-" (symbol-name (car state)) "-state-map"))))
    (add-hook (meq/inconcat "aiern-" (symbol-name (car state)) "-state-exit-hook")
        #'(lambda nil (interactive)
            (meq/which-key--show-popup)))
    (add-hook (meq/inconcat "evil-" (symbol-name (car state)) "-state-entry-hook")
        #'(lambda nil (interactive)
            (meq/which-key--show-popup (meq/inconcat "evil-" (symbol-name (car state)) "-state-map"))))
    (add-hook (meq/inconcat "evil-" (symbol-name (car state)) "-state-exit-hook")
        #'(lambda nil (interactive)
            (meq/which-key--show-popup))))
    aiern-state-properties))

;;;###autoload
(defun meq/which-key--refresh-popup (&optional keymap) (interactive)
    (meq/which-key--hide-popup t)
    (meq/which-key--show-popup keymap t))

;;;###autoload
(defun meq/toggle-which-key (&optional keymap) (interactive)
    (if (cosmoem-any-popup-showing-p)
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
            (funcall which-key-function))
        (setq meq/var/current-top-level-map nil)))

;; Adapted From: https://github.com/justbur/emacs-which-key/blob/master/which-key.el#L1766
(defun which-key--get-keymap-bindings-advice
    (keymap &optional start prefix filter all evil aiern)
  "Retrieve top-level bindings from KEYMAP.
PREFIX limits bindings to those starting with this key
sequence. START is a list of existing bindings to add to.  If ALL
is non-nil, recursively retrieve all bindings below PREFIX. If
EVIL is non-nil, extract active evil bidings; if AIERN is non-nil,
extract active aiern bidings."
  (let ((bindings start)
        (ignore '(self-insert-command ignore ignore-event company-ignore))
        (evil-map
         (when (and evil (bound-and-true-p evil-local-mode))
           (lookup-key keymap (kbd (format "<%s-state>" evil-state)))))
        (aiern-map
         (when (and aiern (bound-and-true-p aiern-local-mode))
           (lookup-key keymap (kbd (format "<%s-state>" aiern-state))))))
    (when (keymapp evil-map)
      (setq bindings (which-key--get-keymap-bindings-1
                      evil-map bindings prefix filter all ignore)))
    (when (keymapp aiern-map)
      (setq bindings (which-key--get-keymap-bindings-1
                      aiern-map bindings prefix filter all ignore)))
    (which-key--get-keymap-bindings-1
     keymap bindings prefix filter all ignore)))

(advice-add #'which-key--get-keymap-bindings :override #'which-key--get-keymap-bindings-advice)

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

;;;###autoload
(defun meq/pre-post-command-hook-command nil (interactive)
    (when (window-minibuffer-p)
      (when (featurep 'alloy)
        (if (or (derived-mode-p 'prog-mode)
                (derived-mode-p 'text-mode))
          (unless (lookup-key
                      alloy-override-mode-map
                      (naked "RET")) (define-key alloy-override-mode-map (naked "RET") 'newline-and-indent)) ;; (alloy-def :keymaps 'override "RET" 'newline-and-indent))
          (when (lookup-key
                  alloy-override-mode-map
                  (naked "RET")) (define-key alloy-override-mode-map (naked "RET") nil) ;; (alloy-def :keymaps 'override "RET" nil)
                  ))))
    (if (or
            ;; (meq/xwinp)
            (derived-mode-p 'vterm-mode))
        (unless meq/var/all-modal-modes-off
            (setq meq/var/backup-modal-modes (meq/current-modal-modes t)
                meq/var/backup-terminal-local-map overriding-terminal-local-map)
            (when (featurep 'vterm) (setq overriding-terminal-local-map vterm-mode-map))
            (meq/disable-all-modal-modes nil t))
        (when meq/var/all-modal-modes-off (mapc #'(lambda (mode) (interactive)
            (when (meq/fbatp mode) (ignore-errors (funcall mode 1)))) meq/var/backup-modal-modes)
            (setq meq/var/backup-modal-modes nil
                meq/var/all-modal-modes-off nil
                overriding-terminal-local-map meq/var/backup-terminal-local-map)))
    (when (featurep 'writeroom-mode)
        (unless (and (meq/fbatp writeroom-mode) (or
                                                    lv-wnd
                                                    (window-minibuffer-p)
                                                    (which-key--popup-showing-p))) (writeroom-mode 1)))
    (when (and (featurep 'olivetti)
            (not (or (derived-mode-p 'dired-mode) (meq/xwinp) (meq/fbatp olivetti-mode))))
        (olivetti-mode 1))
    (when (featurep 'rainbow-identifiers)
        (unless (meq/fbatp rainbow-identifiers-mode) (rainbow-identifiers-mode 1))
        (setq rainbow-identifiers-faces-to-override (face-list)))
    ;; (when (meq/exwm-p) (if (or
    ;;                         (meq/current-modal-modes)
    ;;                         (not (meq/xwinp))
    ;;                         overriding-terminal-local-map
    ;;                         deino-curr-map
    ;;                         hydra-curr-map)
    ;;     (unless (eq exwm--input-mode 'line-mode) (exwm-input-grab-keyboard exwm--id))
    ;;     (unless (eq exwm--input-mode 'char-mode) (exwm-input-release-keyboard exwm--id))))
        )
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
    (when (featurep 'hydra)
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
    (meq/reload-early-init)
    (when (and (featurep 'exwm) (meq/exwm-p))
        (exwm-reset)))

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
(defun meq/substring (substring* string) (string-match-p (regexp-quote substring*) string))

;;;###autoload
(defun meq/remove-dot-dirs (list*) (interactive) (--remove (or (string= "." it) (string= ".." it)) list*))

;; Adapted From: https://github.com/ch11ng/exwm/blob/master/exwm-config.el#L52
;;;###autoload
(defun meq/run (command &optional name)
    (when (meq/exwm-p) (exwm-workspace-switch-create (1+ (exwm-workspace--count))))
    (start-process-shell-command (or name command) nil command)
    (when (and (meq/exwm-p) exwm--floating-frame) (exwm-floating--unset-floating exwm--id)))

;; Adapted From: https://github.com/ch11ng/exwm/blob/master/exwm-config.el#L52
;;;###autoload
(defun meq/run-interactive (command) (interactive (list (read-shell-command "$ ")))
    (when (meq/exwm-p) (exwm-workspace-switch-create (1+ (exwm-workspace--count))))
    (start-process-shell-command command nil command)
    (when (and (meq/exwm-p) exwm--floating-frame) (exwm-floating--unset-floating exwm--id)))

;; ;;;###autoload
;; (defun meq/switch-to-buffer (buffer-or-name) (interactive)
;;     (if (meq/exwm-p)
;;         (exwm-workspace-switch-to-buffer buffer-or-name)
;;         (switch-to-buffer buffer-or-name)))

;; Adapted From: https://github.com/ch11ng/exwm/blob/master/exwm-workspace.el#L978
;;;###autoload
(defun meq/switch-to-buffer-advice (func &rest args)
    "Make the current Emacs window display another buffer."
    (interactive
    (let ((inhibit-quit t))
        ;; Show all buffers
        (unless exwm-workspace-show-all-buffers
        (dolist (pair exwm--id-buffer-alist)
            (with-current-buffer (cdr pair)
            (when (= ?\s (aref (buffer-name) 0))
                (let ((buffer-list-update-hook
                        (remq #'exwm-input--on-buffer-list-update
                            buffer-list-update-hook)))
                (rename-buffer (substring (buffer-name) 1)))))))
        (prog1
            (with-local-quit
            (list (get-buffer (read-buffer-to-switch "Switch to buffer: "))))
        ;; Hide buffers on other workspaces
        (unless exwm-workspace-show-all-buffers
            (dolist (pair exwm--id-buffer-alist)
            (with-current-buffer (cdr pair)
                (unless (or (eq exwm--frame exwm-workspace--current)
                            (= ?\s (aref (buffer-name) 0)))
                (let ((buffer-list-update-hook
                        (remq #'exwm-input--on-buffer-list-update
                                buffer-list-update-hook)))
                    (rename-buffer (concat " " (buffer-name)))))))))))
    (exwm--log)
    (let* ((buffer-or-name (car args))
            (norecord (cadr args))
            (force-same-window (caddr args)))
        (when buffer-or-name
            (if (get-buffer buffer-or-name) (with-current-buffer buffer-or-name
                (if (derived-mode-p 'exwm-mode)
                    ;; EXWM buffer.
                    (if (eq exwm--frame exwm-workspace--current)
                        ;; On the current workspace.
                        (if (not exwm--floating-frame)
                            (apply func args)
                            ;; Select the floating frame.
                            (select-frame-set-input-focus exwm--floating-frame)
                            (select-window (frame-root-window exwm--floating-frame)))
                        ;; On another workspace.
                        (if exwm-layout-show-all-buffers
                            (exwm-workspace-move-window exwm-workspace--current
                                                        exwm--id)
                        (let ((window (get-buffer-window buffer-or-name exwm--frame)))
                            (if window
                                (set-frame-parameter exwm--frame
                                                    'exwm-selected-window window)
                            (set-window-buffer (frame-selected-window exwm--frame)
                                                buffer-or-name)))
                        (exwm-workspace-switch exwm--frame)))
                    ;; Ordinary buffer.
                    (apply func args))) (apply func args)))))

;;;###autoload
(with-eval-after-load 'exwm (add-hook 'exwm-init-hook #'(lambda nil (interactive)
                                                            (advice-add
                                                                #'switch-to-buffer
                                                                :around
                                                                #'meq/switch-to-buffer-advice))))

;;;###autoload
(defun meq/shell nil (interactive)
    (if meq/var/last-buffer
        (progn
            (switch-to-buffer meq/var/last-buffer)
            (setq meq/var/last-buffer nil))
        (setq meq/var/last-buffer (buffer-name))
        (if (meq/exwm-p)
            (if (get-buffer "Alacritty") (switch-to-buffer "Alacritty") (meq/run "alacritty"))
            (vterm))))

;;;###autoload
(defun meq/test nil (interactive) (message (meq/timestamp)))

;;;###autoload
(defun meq/which-key-change (keymap key name &optional hook) (interactive)
    (when (featurep 'which-key)
        (let* ((keys (split-string key " "))
                (keymap-name (symbol-name (meq/keymap-symbol keymap)))
                (keymap-keyword (meq/inconcat ":" keymap-name))

                ;; Adapted From:
                ;; Answer: https://emacs.stackexchange.com/questions/30864/relocating-an-anonymous-prefix-keymap
                ;; User: https://emacs.stackexchange.com/users/8528/ivan
                (super-lookup (concat
                    (string-join (mapcar #'(lambda (key) (interactive) "(lookup-key") keys) " ")
                    " "
                    keymap-name
                    " "
                    (string-join (mapcar #'(lambda (key) (interactive) (concat "\"" key "\"" ")")) keys) " "))))

            (add-hook (or hook 'after-init-hook) #'(lambda nil (interactive)
                (which-key-add-keymap-based-replacements keymap key (cons
                    name

                    ;; Adapted From:
                    ;; Answer: https://emacs.stackexchange.com/questions/19877/how-to-evaluate-elisp-code-contained-in-a-string
                    ;; User: https://emacs.stackexchange.com/users/2355/constantine
                    (eval (car (read-from-string (format "(progn %s)" super-lookup)))))))))))

;;;###autoload
(defun meq/which-key-change-ryo (key name &optional hook) (interactive)
    `(when (featurep 'ryo-modal)
        (meq/which-key-change ryo-modal-mode-map ,key ,name ,hook)))

;;;###autoload
(meq/which-key-change-ryo ";" "meq")

;;;###autoload
(defun meq/which-key-change-sorrow (key name &optional hook) (interactive)
    (when (featurep 'sorrow)
        (meq/which-key-change sorrow-mode-map key name hook)))

;; Adapted From: https://www.reddit.com/r/emacs/comments/caifq4/package_updates_with_straight/et99epi?utm_source=share&utm_medium=web2x&context=3
;; And: https://github.com/raxod502/straight.el#updating-recipe-repositories
;;;###autoload
(defun meq/straight-upgrade nil (interactive)
    (when (featurep 'straight) (straight-pull-all)
    (straight-merge-all)
    (straight-freeze-versions))
    (when (and (not (daemonp)) (featurep 'restart-emacs))
        (restart-emacs)))

;; Adapted From:
;; Answer: https://emacs.stackexchange.com/a/20122/31428
;; User: https://emacs.stackexchange.com/users/962/harald-hanche-olsen
;;;###autoload
(defmacro meq/with-ymm (&rest args)
    (when (featurep 'yasnippet) (yas-minor-mode 1) (eval `(progn ,@args)) (yas-minor-mode 0)))

;;;###autoload
(defun meq/insert-snippet (name)
    (when (featurep 'yasnippet) (eval `(meq/with-ymm (yas-expand-snippet (yas-lookup-snippet ,name))))))

;;;###autoload
(defun meq/get-next-in-list (item list)
    (let* ((index (seq-position list item))
            (value (when index (nth (1+ index) list))))
        (when value (unwind-protect value (delete value list)))))

;;;###autoload
(defun meq/get-next-in-cla (item) (meq/get-next-in-list item command-line-args))

;;;###autoload
(defun meq/item-in-list (item list) (unwind-protect (member item list) (delete item list)))

;;;###autoload
(defun meq/item-in-cla (item) (meq/item-in-list item command-line-args))

;;;###autoload
(defun meq/two-items-in-list (item list) (unwind-protect (when (member item list) (meq/get-next-in-list item list)) (delete item list)))

;;;###autoload
(defun meq/two-items-in-cla (item) (meq/two-items-in-list item command-line-args))

;;;###autoload
(defmacro meq/if-item-in-list (item list &rest body)
    (let* ((peabody* (pop body))
            (peabody (if (stringp peabody*) (list peabody*) peabody*)))
        (if (member item list)
            (unwind-protect (eval `(progn ,@peabody)) (delete item list))
            (eval `(progn ,@body)))))

;;;###autoload
(defmacro meq/if-item-in-cla (item &rest body) (eval `(meq/if-item-in-list ,item ,command-line-args ,@body)))

;;;###autoload
(defmacro meq/if-two-items-in-list (item list &rest body)
    (let* ((value (meq/get-next-in-list item list))
            (peabody* (pop body))
            (return-peabody (and (booleanp peabody*) peabody*))
            (peabody (if (stringp peabody*) (list peabody*) peabody*)))
        (if (member item list)
            (unwind-protect (if return-peabody value (eval `(progn ,@peabody))) (delete item list))
            (eval `(progn ,@body)))))

;;;###autoload
(defmacro meq/if-two-items-in-cla (item &rest body)
    (eval `(meq/if-two-items-in-list ,item ,command-line-args ,@body)))

;;;###autoload
(defmacro meq/when-item-in-list (item list &rest body)
    (when (member item list) (unwind-protect (eval `(progn ,@body)) (delete item list))))

;;;###autoload
(defmacro meq/when-item-in-cla (item &rest body)
    (eval `(meq/when-item-in-list ,item ,command-line-args ,@body)))

;;;###autoload
(defmacro meq/when-two-items-in-list (item list return &rest body)
    (let* ((value (meq/get-next-in-list item list)))
        (when (member item list) (unwind-protect
                                    (if return value (eval `(progn ,@body)))
                                    (delete item list)))))

;;;###autoload
(defmacro meq/when-two-items-in-cla (item return &rest body)
    (eval `(meq/when-two-items-in-list ,item ,command-line-args ,return ,@body)))

;;;###autoload
(defmacro meq/unless-item-in-list (item list &rest body)
    (unless (meq/item-in-list item list) (eval `(progn ,@body))))

;;;###autoload
(defmacro meq/unless-item-in-cla (item &rest body)
    (eval `(meq/unless-item-in-list ,item ,command-line-args ,@body)))

;;;###autoload
(defmacro meq/unless-two-items-in-list (item list return &rest body)
    (let* ((value (meq/get-next-in-list item list)))
        (unless (meq/item-in-list item list) (if return value (eval `(progn ,@body))))))

;;;###autoload
(defmacro meq/unless-two-items-in-cla (item return &rest body)
    (eval `(meq/unless-two-items-in-list ,item ,command-line-args ,return ,@body)))

;;;###autoload
(defun meq/rs* (item) (if (stringp item) item (symbol-name item)))

;;;###autoload
(defun meq/rs (item &optional popstar)
    (cond ((meq/listtp item) (meq/rs* (if popstar (pop item) (car item))))
            (t (meq/rs* item))))

;;;###autoload
(defun meq/rl (item) (if (meq/listtp item) item (list item)))

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

;; Adapted From: https://github.com/jojojames/dired-sidebar/blob/master/dired-sidebar.el#L670
;; And: https://github.com/jojojames/dired-sidebar/blob/master/dired-sidebar.el#L660
;;;###autoload
(defun meq/dired-sidebar-toggle nil (interactive)
    (when (featurep 'dired-sidebar)
        (if (dired-sidebar-showing-sidebar-p)
            (if (equal (current-buffer) (dired-sidebar-buffer))
                (dired-sidebar-hide-sidebar)
                (dired-sidebar-jump-to-sidebar))
            (dired-sidebar-jump-to-sidebar))))

;;;###autoload
(defun meq/backslash-toggle (&optional ua) (interactive "p")
    (if current-prefix-arg
        (cond ((= ua 4) (meq/toggle-which-key)))
        (meq/dired-sidebar-toggle)))

(provide 'meq)
;;; meq.el ends here
