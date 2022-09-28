;;; trivial-adoc-mode.el --- Bare-bones major mode for AsciiDoc -*- lexical-binding: t -*-

;; Copyright 2021 Lassi Kortela
;; SPDX-License-Identifier: ISC

;; Author: Lassi Kortela
;; URL: https://github.com/lassik/emacs-trivial-adoc-mode
;; Version: 0.1.0
;; Package-Requires: ((emacs "24.5"))
;; Keywords: languages wp

;; This file is not part of GNU Emacs.

;;; Commentary:

;; This is an intentionally bare-bones editing more for AsciiDoc
;; markup. The `adoc-mode' from MELPA does fancy things with font-lock
;; which can make it hard to discern the exact markup you are using -
;; particularly important when source code snippets are embedded in
;; documents.

;;; Code:

(defconst trivial-adoc-mode-attribute-name-regex "[a-z0-9_][a-z0-9_-]*")

(defconst trivial-adoc-mode-font-lock-keywords
  `(;; Heading:
    ("^\\(=+\\|#+\\) +\\(.*\\)$"
     (1 font-lock-keyword-face)
     (2 font-lock-preprocessor-face))
    ;; Attribute:
    (,(concat "^\\(:" trivial-adoc-mode-attribute-name-regex ":\\) * \\(\\(.*?\\\\\n\\)*.*\\)$")
     (1 font-lock-constant-face)
     (2 font-lock-string-face))
    ;; Attribute reference:
    (,(concat "{" trivial-adoc-mode-attribute-name-regex "}")
     (0 font-lock-constant-face))
    ;; List item:
    ("^ *\\(\\*+\\) +\\(.*\\)"
     (1 font-lock-keyword-face)
     (2 font-lock-type-face))
    ;; Blocks
    ("^\\[.*\\]$"
     (0 font-lock-keyword-face))
    ;; Table delimiter line:
    ("^|=+$"
     (0 font-lock-keyword-face))
    ;; Table row:
    ("^|.*$"
     (0 font-lock-variable-name-face))
    ;; Macro calls
    ("")
    ;; Inline preformatted:
    ("`.*?`"
     (0 font-lock-string-face)))
  "Font-lock syntax patterns for `trivial-adoc-mode'.")

(defun trivial-adoc-mode-maybe-end-sentence ()
  "Insert dot and go to new line if guessing this is the end of a sentence."
  (interactive)
  (insert ".")
  (when (looking-back "\\s \\w*\\w\\{3\\}\\." 20)
      (insert "\n")))


(defvar trivial-adoc-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "."  #'trivial-adoc-mode-maybe-end-sentence)
    map))


;;;###autoload
(define-derived-mode trivial-adoc-mode text-mode "adoc"
  "A bare-bones major mode for AsciiDoc markup.

AsciiDoc is a text markup language similar to Markdown. Its home
page is at the URL `https://asciidoc.org/'.

`trivial-adoc-mode` is a lightweight alternative to `adoc-mode`.
The trivial one does not do any fancy text formatting via Emacs
faces. Instead, it provides very bare-bones syntax highlighting.

\\{trivial-adoc-mode-map}"
  ;; Setup font-lock.
  (setq-local font-lock-defaults '(trivial-adoc-mode-font-lock-keywords nil t)
              font-lock-multiline t
              sentence-end-double-space nil))


;;;###autoload
(add-to-list 'auto-mode-alist '("\\.adoc$" . trivial-adoc-mode))

(defun adoc-reformat-paragrpah ()
  "Break a long line or text block into multiple lines by ending period.
Work on text selection if there is one, else the current text block.
URL `http://xahlee.info/emacs/emacs/elisp_reformat_to_sentence_lines.html'
Version 2020-12-02 2021-04-14 2021-08-01"
  (interactive)
  (let ($p1 $p2)
    (if (use-region-p)
        (setq $p1 (region-beginning) $p2 (region-end))
      (progn
        (if (re-search-backward "\n[ \t]*\n+" nil "move")
            (progn (re-search-forward "\n[ \t]*\n+")
                   (setq $p1 (point)))
          (setq $p1 (point)))
        (re-search-forward "\n[ \t]*\n" nil "move")
        (setq $p2 (point))))
    (save-restriction
      (narrow-to-region $p1 $p2)
      (progn (goto-char (point-min)) (while (search-forward "\n" nil t) (replace-match " " )))
      (progn (goto-char (point-min)) (while (re-search-forward "  +" nil t) (replace-match " " )))
      (progn (goto-char (point-min)) (while (re-search-forward "\\. +\\([0-9A-Za-z]+\\)" nil t) (replace-match ".\n\\1" )))
      (progn (goto-char (point-min)) (while (search-forward " <a " nil t) (replace-match "\n<a " )))
      (progn (goto-char (point-min)) (while (search-forward "</a>" nil t) (replace-match "</a>\n" )))
      (goto-char (point-max))
      (while (eq (char-before ) 32) (delete-char -1))
      (insert "\n\n"))))

(provide 'trivial-adoc-mode)

;;; trivial-adoc-mode.el ends here
