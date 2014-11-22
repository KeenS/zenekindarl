(in-package :cl-user)
(defpackage clta.parse
  (:use :cl
        :esrap
        :clta.att
        :clta.syntax-table
        :clta.syntax-table.default)
  (:import-from :alexandria
                :read-file-into-string)
  (:export :parse-template-string
           :parse-template-file))
(in-package clta.parse)

(defun parse-template-string (str)
  (parse 'template str))

(defun parse-template-file (file)
  (parse-template-string (read-file-into-string file)))
