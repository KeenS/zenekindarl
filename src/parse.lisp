(in-package :cl-user)
(defpackage arrows.parse
  (:use :cl
        :esrap
        :arrows.att
        :arrows.syntax-table
        :arrows.syntax-table.default)
  (:import-from :alexandria
                :read-file-into-string)
  (:export :parse-template-string
           :parse-template-file))
(in-package arrows.parse)

(defun parse-template-string (str)
  (parse 'template str))

(defun parse-template-file (file)
  (parse-template-string (read-file-into-string file)))
