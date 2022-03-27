;;; org-preview-image-link-posframe --- Show the margin note at point  -*- lexical-binding: t; -*-

;; Copyright (C) 2022 Ran Wang

;; Author: Ran Wang
;; URL: https://github.com/randomwangran/org-preview-image-link-posframe
;; Version: 0.0.1
;; Package-Requires: ((emacs "27.1") (org "9.4") (posframe "1.1.5")
;; Keywords: org-mode, preview, writing, note-taking, posframe

;; This file is not part of GNU Emacs.

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

;; This package preview an image at a link.

;;;; Installation

;;;;; MELPA

;; This package is not available on MELPA. Manual installation required.

;;;;; Manual

;; Install these required packages:

;; Then put this file in your load-path, and put this in your init
;; file:
;; (require 'org-preview-image-link-posframe)

(require 'org)
(require 'posframe)

(defvar org-preview-image-link-posframe--tmp-buf " opilp-tmp-buf")

(defcustom opilp-off-set 500
  "The off-set for showing the image at point."
  :type 'integer
  :safe #'integerp)

(defun org-preview-image-link-posframe (point)
  (interactive "d")
  (posframe-delete-all)
  (let* ((context
	  (plist-get (car (cdr (org-element-lineage
	                        (org-element-context)
	                        '(link)
	                        t))) ':raw-link))
         (point (save-excursion
                (widen)
		(goto-char (point-min))
		(re-search-forward (concat "#\\+name:\s*" context) nil t)
                (re-search-forward org-bracket-link-regexp nil t)))
         (path (save-excursion
                 (widen)
		 (goto-char point)
                 (let* ((element (org-element-context))
                        (path (expand-file-name (org-element-property :path element))))
                   (with-current-buffer
                       (get-buffer-create org-preview-image-link-posframe--tmp-buf)
                     (erase-buffer)
                     (insert-image (create-image path 'png nil :width 300))
                     (image-mode)))))))
  (when (posframe-workable-p)
    (posframe-show org-preview-image-link-posframe--tmp-buf
                   :position (point)
                   :x-pixel-offset opilp-off-set)
     (clear-this-command-keys) ;; https://emacs-china.org/t/posframe/9374/2
     (push (read-event) unread-command-events)
     (posframe-delete org-preview-image-link-posframe--tmp-buf)))

(provide 'org-preview-image-link-posframe)
