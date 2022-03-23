(defvar org-preview-image-link-posframe--tmp-buf " opilp-tmp-buf")

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
                   :position (point))))
