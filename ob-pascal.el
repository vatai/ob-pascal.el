;;; ob-pascal.el --- org-babel functions for pascal evaluation

;; Copyright (C) 2011-2014 Free Software Foundation, Inc.

;; Author: Emil Vatai
;; Keywords: literate programming, reproducible research
;; Homepage: http://sublime.inf.elte.hu/~vatai/

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; 

;;; Code:
(require 'ob)

(defvar org-babel-tangle-lang-exts)
(add-to-list 'org-babel-tangle-lang-exts '("pascal" . "pas"))

;; TODO what do I do with this
(defvar org-babel-pascal-command ""
  "Name of the pascal command.")

(defvar org-babel-pascal-compiler "fpc"
  "Name of the pascal compiler (free pascal compiler).")

(defun org-babel-execute:pascal (body params)
  ; (cdr (assoc :strange params))

  (let* ((tmp-src-file (org-babel-temp-file "pascal-src-" ".pas" ))
         (tmp-bin-file (org-babel-temp-file "pascal-bin-" org-babel-exeext))
         (cmdline (cdr (assoc :cmdline params)))
         (flags (cdr (assoc :flags params)))
	 ;; TODO wrap in a program stg; var 
         ;; (full-body (org-babel-C-expand body params))
         (compile
	  (progn
	    (with-temp-file tmp-src-file (insert body))
	    (org-babel-eval
	     ; compiler -o tmp-bin-file flags tmp tmp-src-file
	     (format "%s -o%s %s %s" 
		     org-babel-pascal-compiler
		     (org-babel-process-file-name tmp-bin-file)
		     (mapconcat 'identity
				(if (listp flags) flags (list flags)) " ")
		     (org-babel-process-file-name tmp-src-file)) ""))))
    (let ((results
           (org-babel-trim
            (org-babel-eval
             (concat tmp-bin-file (if cmdline (concat " " cmdline) "")) ""))))
      (org-babel-reassemble-table
       (org-babel-result-cond (cdr (assoc :result-params params))
	 (org-babel-read results)
         (let ((tmp-file (org-babel-temp-file "pas-")))
           (with-temp-file tmp-file (insert results))
           (org-babel-import-elisp-from-file tmp-file)))
       (org-babel-pick-name
        (cdr (assoc :colname-names params)) (cdr (assoc :colnames params)))
       (org-babel-pick-name
        (cdr (assoc :rowname-names params)) (cdr (assoc :rownames params)))))
    ))
(provide 'ob-pascal)



;;; ob-java.el ends here
