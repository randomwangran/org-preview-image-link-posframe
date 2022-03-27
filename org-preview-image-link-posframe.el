;;; org-preview-image-link-posframe --- Show the preview image from an org-mode image link  -*- lexical-binding: t; -*-

;; Copyright (C) 2022 Ran Wang

;; Author: Ran Wang
;; URL: https://github.com/randomwangran/org-preview-image-link-posframe
;; Version: 0.0.1
;; Package-Requires: ((emacs "27.1") (org "9.4") (posframe "1.1.5") (avy "0.5.0"))
;; Keywords: org-mode, preview, writing, note-taking, posframe, avy

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

;; This package preview an image on the fly.

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
(require 'avy)

(defvar org-preview-image-link-posframe--tmp-buf " opilp-tmp-buf")

(defcustom opilp-off-set 500
  "The off-set for showing the image at point."
  :type 'integer
  :safe #'integerp)

(defcustom opilp-off-threshold 35
  "The threshold for determining the location of the image.

For showing the figure at approxiately the same location. It is
just a workaround."
  :type 'integer
  :safe #'integerp)

(defun org-preview-image-link-posframe (point)
  "Preview the image at an org-link. After the execution, the
default response for the next action is to delete the posframe
when any input is received from the user.

With a univeral argument, the posframe will hold on there. This
is useful for writing descriptions for the figure without lossing
its content. In this case, the way to delete the posframe frame
is to press `C-g`. "
  (interactive "d")
  (let* ((context
	  (plist-get (car (cdr (org-element-lineage
	                        (org-element-context)
	                        '(link)
	                        t))) ':raw-link))
         (point (save-restriction
                  (save-excursion
                    (widen)
		    (goto-char (point-min))
		    (re-search-forward (concat "#\\+name:\s*" context) nil t)
                    (re-search-forward org-bracket-link-regexp nil t))))
         (path (save-restriction
                 (save-excursion
                   (widen)
		   (goto-char point)
                   (let* ((element (org-element-context))
                          (path (expand-file-name (org-element-property :path element))))
                     (with-current-buffer
                         (get-buffer-create org-preview-image-link-posframe--tmp-buf)
                       (erase-buffer)
                       (insert-image (create-image path 'png nil :width 300))
                       (image-mode))))))))
  (when (posframe-workable-p)
    (if  (equal current-prefix-arg nil)
        (progn (if (< (current-column) opilp-off-threshold)
                   (posframe-show org-preview-image-link-posframe--tmp-buf
                                  :position (point)
                                  :x-pixel-offset opilp-off-set)
                 (posframe-show org-preview-image-link-posframe--tmp-buf
                                :position (point)
                                :x-pixel-offset (- opilp-off-set 200)))
               (clear-this-command-keys)
               (push (read-event) unread-command-events)
               (posframe-delete org-preview-image-link-posframe--tmp-buf))
      (progn (if (< (current-column) opilp-off-threshold)
                 (posframe-show org-preview-image-link-posframe--tmp-buf
                                :position (point)
                                :x-pixel-offset opilp-off-set)
               (posframe-show org-preview-image-link-posframe--tmp-buf
                              :position (point)
                              :x-pixel-offset (- opilp-off-set 200)))))))

(defun avy-preview-figure (point)
  "Use avy to preview the image without lossing the point position."
  (interactive "d")
  (save-restriction
    (save-excursion
      (goto-char (nth 0 (avy--generic-jump "Fig\\|Figs\\|Figure\\|Figures" nil)))
      (search-forward "[[")
      (call-interactively #'org-preview-image-link-posframe)
      (goto-char point))))

(defun avy-preview-figure-hold (point)
  "Use avy to preview the image without lossing the point position.

The image is hold on."
  (interactive "d")
  (goto-char (nth 0 (avy--generic-jump "Fig\\|Figs\\|Figure\\|Figures" nil)))
  (search-forward "[[")
  (let ((current-prefix-arg 1))
    (call-interactively #'org-preview-image-link-posframe)
    (goto-char point)))

(advice-add 'keyboard-quit :around
            (lambda (&rest _)
              (posframe-delete-all)))

(provide 'org-preview-image-link-posframe)
