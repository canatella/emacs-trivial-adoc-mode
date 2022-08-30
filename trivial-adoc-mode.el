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
  (setq-local font-lock-defaults
              '(trivial-adoc-mode-font-lock-keywords nil t))
  (setq-local font-lock-multiline
              t))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.adoc$" . trivial-adoc-mode))

(provide 'trivial-adoc-mode)

;;; trivial-adoc-mode.el ends here
