;;; meq-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (directory-file-name (or (file-name-directory #$) (car load-path))))

;;;### (autoloads nil "meq" "meq.el" (0 0 0 0))
;;; Generated autoloads from meq.el

(autoload 'meq/ued "meq" "\


\(fn &rest ARGS)" nil nil)

(autoload 'meq/ued-lib "meq" "\


\(fn &rest ARGS)" nil nil)

(autoload 'meq/ued-siluam "meq" "\


\(fn &rest ARGS)" nil nil)

(autoload 'meq/ued-profiles "meq" "\


\(fn &rest ARGS)" nil nil)

(autoload 'meq/ued-settings "meq" "\


\(fn &rest ARGS)" nil nil)

(autoload 'meq/ued-local "meq" "\


\(fn &rest ARGS)" nil nil)

(autoload 'meq/cl "meq" "\


\(fn &rest ARGS)" nil nil)

(autoload 'meq/load-emacs-file "meq" "\


\(fn &rest FILES)" nil nil)

(autoload 'meq/load-siluam-file "meq" "\


\(fn &rest FILES)" nil nil)

(autoload 'meq/timestamp "meq" nil t nil)

(autoload 'meq/pget "meq" "\


\(fn ITEM PLIST)" nil nil)

(autoload 'meq/basename "meq" "\


\(fn &optional FILE)" t nil)

(autoload 'meq/keyword-to-symbol-name "meq" "\


\(fn KEYWORD)" t nil)

(autoload 'meq/inconcat "meq" "\


\(fn &rest STRINGS)" nil nil)

(autoload 'meq/fbatp "meq" "\


\(fn MODE)" t nil)

(autoload 'meq/ncp "meq" nil t nil)

(autoload 'meq/listtp "meq" "\


\(fn LIST*)" t nil)

(autoload 'meq/exwm-p "meq" nil t nil)

(autoload 'meq/xwinp "meq" nil t nil)

(autoload 'meq/windows-p "meq" nil t nil)

(autoload 'meq/org-babel-restart-session-to-point "meq" "\
Restart session up to the src-block in the current point.
Goes to beginning of buffer and executes each code block with
`org-babel-execute-src-block' that has the same language and
session as the current block. ARG has same meaning as in
`org-babel-execute-src-block'.

\(fn &optional ARG)" t nil)

(autoload 'meq/org-babel-kill-session "meq" "\
Kill session for current code block." t nil)

(autoload 'meq/org-babel-remove-result-buffer "meq" "\
Remove results from every code block in buffer." t nil)

(autoload 'meq/outline-on-heading-p "meq" "\
Returns non-nil if point is on a headline." t nil)

(autoload 'meq/foldable-p "meq" "\
Returns non-nil if point can fold." t nil)

(autoload 'meq/folded-p "meq" "\
Returns non-nil if point is on a folded org object." t nil)

(autoload 'meq/unfolded-p "meq" "\
Returns non-nil if point is on an unfolded org object." t nil)

(autoload 'meq/go-to-parent "meq" "\


\(fn &optional STEPS)" t nil)

(autoload 'meq/prior-char "meq" "\


\(fn &optional *POINT)" t nil)

(autoload 'meq/whitespace-p "meq" "\


\(fn &optional *POINT)" t nil)

(autoload 'meq/newline-p "meq" "\


\(fn &optional *POINT)" t nil)

(autoload 'meq/delete-while-white "meq" "\


\(fn &optional *NOT)" t nil)

(autoload 'meq/delete-white-or-word "meq" nil t nil)

(autoload 'meq/outline-cycle "meq" "\


\(fn FUNC &rest ARGS)" t nil)

(autoload 'meq/tab "meq" "\


\(fn &optional TAB-SIZE-IN-SPACES)" nil nil)

(autoload 'meq/untab "meq" "\


\(fn &optional TAB-SIZE-IN-SPACES)" t nil)

(autoload 'meq/outline-indent "meq" "\


\(fn UNTAB)" t nil)

(autoload 'meq/outline-cycle-indent "meq" "\


\(fn UNTAB FUNC &rest ARGS)" t nil)

(advice-add #'org-cycle :around #'(lambda (func &rest args) (interactive) (apply #'meq/outline-cycle-indent nil func args)))

(advice-add #'org-shifttab :around #'(lambda (func &rest args) (interactive) (apply #'meq/outline-cycle-indent t func args)))

(autoload 'meq/org-babel-tangle-append "meq" "\
Append source code block at point to its tangle file.
    The command works like `org-babel-tangle' with prefix arg
    but `delete-file' is ignored." t nil)

(autoload 'meq/org-babel-tangle-collect-blocks-handle-tangle-list "meq" "\
Can be used as :override advice for `org-babel-tangle-collect-blocks'.
    Handles lists of :tangle files.

\(fn &optional LANGUAGE TANGLE-FILE)" nil nil)

(autoload 'meq/org-babel-tangle-single-block-handle-tangle-list "meq" "\
Can be used as :around advice for `org-babel-tangle-single-block'.
    If the :tangle header arg is a list of files. Handle all files

\(fn OLDFUN BLOCK-COUNTER &optional ONLY-THIS-BLOCK)" nil nil)

(autoload 'meq/get-tangled-file-name "meq" "\


\(fn &optional FILE*)" t nil)

(autoload 'meq/org-babel-detangle-and-return "meq" "\


\(fn &optional FILE* ORIGIN*)" t nil)

(autoload 'meq/org-babel-detangle-kill-and-return "meq" "\


\(fn FILE &optional ORIGIN)" t nil)

(autoload 'meq/generate-obdar "meq" "\


\(fn FILE &optional ORIGIN)" nil nil)

(autoload 'meq/moff "meq" "\


\(fn MODE)" nil nil)

(autoload 'meq/after-init "meq" nil t nil)

(autoload 'meq/src-mode-settings "meq" nil t nil)

(autoload 'meq/src-mode-exit "meq" nil t nil)

(advice-add #'org-edit-special :after #'meq/src-mode-settings)

(advice-add #'org-babel-tangle-collect-blocks :override #'meq/org-babel-tangle-collect-blocks-handle-tangle-list)

(advice-add #'org-babel-tangle-single-block :around #'meq/org-babel-tangle-single-block-handle-tangle-list)

(autoload 'meq/narrow-or-widen-dwim "meq" "\
Widen if buffer is narrowed, narrow-dwim otherwise.
    Dwim means: region, org-src-block, org-subtree, or
    defun, whichever applies first. Narrowing to
    org-src-block actually calls `org-edit-src-code'.

    With prefix P, don't widen, just narrow even if buffer
    is already narrowed.

\(fn P)" t nil)

(autoload 'meq/disable-all-modal-modes "meq" "\


\(fn &optional KEYMAP INCLUDE-IGNORED)" t nil)

(autoload 'meq/end-of-line-and-indented-new-line "meq" nil t nil)

(autoload 'meq/which-key--hide-popup "meq" "\


\(fn &optional FORCE DONT-DISABLE-MODAL-MODES)" t nil)

(autoload 'meq/window-divider "meq" nil nil nil)

(autoload 'meq/which-key--show-popup "meq" "\


\(fn &optional KEYMAP FORCE DISABLE-MODAL-MODES)" t nil)

(with-eval-after-load 'aiern (mapc #'(lambda (state) (interactive) (add-hook (meq/inconcat "aiern-" (symbol-name (car state)) "-state-entry-hook") #'(lambda nil (interactive) (meq/which-key--show-popup (meq/inconcat "aiern-" (symbol-name (car state)) "-state-map")))) (add-hook (meq/inconcat "aiern-" (symbol-name (car state)) "-state-exit-hook") #'(lambda nil (interactive) (meq/which-key--show-popup))) (add-hook (meq/inconcat "evil-" (symbol-name (car state)) "-state-entry-hook") #'(lambda nil (interactive) (meq/which-key--show-popup (meq/inconcat "evil-" (symbol-name (car state)) "-state-map")))) (add-hook (meq/inconcat "evil-" (symbol-name (car state)) "-state-exit-hook") #'(lambda nil (interactive) (meq/which-key--show-popup)))) aiern-state-properties))

(autoload 'meq/which-key--refresh-popup "meq" "\


\(fn &optional KEYMAP)" t nil)

(autoload 'meq/toggle-which-key "meq" "\


\(fn &optional KEYMAP)" t nil)

(autoload 'meq/which-key-show-top-level "meq" "\


\(fn &optional KEYMAP)" t nil)

(autoload 'meq/newline-and-indent-advice "meq" "\


\(fn FUNC &rest ARGUMENTS)" nil nil)

(autoload 'meq/current-modal-modes "meq" "\


\(fn &optional INCLUDE-IGNORED)" t nil)

(autoload 'meq/keymap-symbol "meq" "\
Return the symbol to which KEYMAP is bound, or nil if no such symbol exists.

\(fn KEYMAP)" t nil)

(autoload 'meq/pre-post-command-hook-command "meq" nil t nil)

(add-hook 'pre-command-hook 'meq/pre-post-command-hook-command)

(add-hook 'post-command-hook 'meq/pre-post-command-hook-command)

(autoload 'meq/evil-ex-advice "meq" "\


\(fn FUNC &rest ARGUMENTS)" nil nil)

(with-eval-after-load 'aiern (advice-add #'aiern-ex :around #'meq/evil-ex-advice))

(with-eval-after-load 'evil (advice-add #'evil-ex :around #'meq/evil-ex-advice))

(autoload 'meq/doom/escape "meq" "\
Run `doom-escape-hook'.

\(fn &optional INTERACTIVE)" t nil)

(advice-add #'keyboard-quit :override #'meq/doom/escape)

(autoload 'meq/M-x "meq" nil t nil)

(autoload 'meq/untabify-everything "meq" nil nil nil)

(autoload 'meq/untabify-except-makefiles "meq" "\
Replace tabs with spaces except in makefiles." nil nil)

(add-hook 'before-save-hook 'meq/untabify-except-makefiles)

(autoload 'meq/god-prefix-command-p "meq" "\
Return non-nil if the current command is a \"prefix\" command.
This includes prefix arguments and any other command that should
be ignored by `god-execute-with-current-bindings'." nil nil)

(autoload 'meq/hydra-force-disable "meq" "\
Disable the current Hydra." t nil)

(autoload 'meq/reload-emacs "meq" nil t nil)

(autoload 'meq/remove-dot-dirs "meq" "\


\(fn LIST*)" t nil)

(autoload 'meq/run "meq" "\


\(fn COMMAND &optional NAME)" nil nil)

(autoload 'meq/run-interactive "meq" "\


\(fn COMMAND)" t nil)

(autoload 'meq/switch-to-buffer-advice "meq" "\
Make the current Emacs window display another buffer.

\(fn FUNC &rest ARGS)" t nil)

(with-eval-after-load 'exwm (add-hook 'exwm-init-hook #'(lambda nil (interactive) (advice-add #'switch-to-buffer :around #'meq/switch-to-buffer-advice))))

(autoload 'meq/shell "meq" nil t nil)

(autoload 'meq/test "meq" nil t nil)

(autoload 'meq/which-key-change "meq" "\


\(fn KEYMAP KEY NAME &optional HOOK)" t nil)

(autoload 'meq/which-key-change-ryo "meq" "\


\(fn KEY NAME &optional HOOK)" t nil)

(meq/which-key-change-ryo ";" "meq")

(autoload 'meq/which-key-change-sorrow "meq" "\


\(fn KEY NAME &optional HOOK)" t nil)

(autoload 'meq/straight-upgrade "meq" nil t nil)

(autoload 'meq/with-ymm "meq" "\


\(fn &rest ARGS)" nil t)

(autoload 'meq/insert-snippet "meq" "\


\(fn NAME)" nil nil)

(autoload 'meq/get-next-in-list "meq" "\


\(fn ITEM LIST)" nil nil)

(autoload 'meq/get-next-in-cla "meq" "\


\(fn ITEM)" nil nil)

(autoload 'meq/item-in-list "meq" "\


\(fn ITEM LIST)" nil nil)

(autoload 'meq/item-in-cla "meq" "\


\(fn ITEM)" nil nil)

(autoload 'meq/two-items-in-list "meq" "\


\(fn ITEM LIST)" nil nil)

(autoload 'meq/two-items-in-cla "meq" "\


\(fn ITEM)" nil nil)

(autoload 'meq/if-item-in-list "meq" "\


\(fn ITEM LIST &rest BODY)" nil t)

(autoload 'meq/if-item-in-cla "meq" "\


\(fn ITEM &rest BODY)" nil t)

(autoload 'meq/if-two-items-in-list "meq" "\


\(fn ITEM LIST &rest BODY)" nil t)

(autoload 'meq/if-two-items-in-cla "meq" "\


\(fn ITEM &rest BODY)" nil t)

(autoload 'meq/when-item-in-list "meq" "\


\(fn ITEM LIST &rest BODY)" nil t)

(autoload 'meq/when-item-in-cla "meq" "\


\(fn ITEM &rest BODY)" nil t)

(autoload 'meq/when-two-items-in-list "meq" "\


\(fn ITEM LIST RETURN &rest BODY)" nil t)

(autoload 'meq/when-two-items-in-cla "meq" "\


\(fn ITEM RETURN &rest BODY)" nil t)

(autoload 'meq/unless-item-in-list "meq" "\


\(fn ITEM LIST &rest BODY)" nil t)

(autoload 'meq/unless-item-in-cla "meq" "\


\(fn ITEM &rest BODY)" nil t)

(autoload 'meq/unless-two-items-in-list "meq" "\


\(fn ITEM LIST RETURN &rest BODY)" nil t)

(autoload 'meq/unless-two-items-in-cla "meq" "\


\(fn ITEM RETURN &rest BODY)" nil t)

(autoload 'meq/rs* "meq" "\


\(fn ITEM)" nil nil)

(autoload 'meq/rs "meq" "\


\(fn ITEM &optional POPSTAR)" nil nil)

(autoload 'meq/rl "meq" "\


\(fn ITEM)" nil nil)

(with-eval-after-load 'aiern (with-eval-after-load 'evil (defun meq/both-ex-define-cmd (cmd function) (interactive) (evil-ex-define-cmd cmd function) (aiern-ex-define-cmd cmd function))))

(with-eval-after-load 'counsel (advice-add #'counsel-M-x :before #'meq/which-key--hide-popup))

(with-eval-after-load 'helm (advice-add #'helm-smex-major-mode-commands :before #'meq/which-key--hide-popup) (advice-add #'helm-smex :before #'meq/which-key--hide-popup))

(advice-add #'keyboard-escape-quit :after #'meq/which-key--show-popup)

(advice-add #'keyboard-quit :after #'meq/which-key--show-popup)

(advice-add #'exit-minibuffer :after #'meq/which-key--show-popup)

(add-hook 'after-init-hook 'key-chord-mode)

(autoload 'meq/dired-sidebar-toggle "meq" nil t nil)

(autoload 'meq/backslash-toggle "meq" "\


\(fn &optional UA)" t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "meq" '("meq/" "which-key--get-keymap-bindings-advice")))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; meq-autoloads.el ends here
