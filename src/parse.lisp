(in-package :cl-user)
(defpackage zenekindarl.parse
  (:use :cl
        :zenekindarl.att
        :zenekindarl.lexer
        :zenekindarl.parser)
  (:import-from :alexandria
                :read-file-into-string)
  (:export :parse-template-string
           :parse-template-file))
(in-package zenekindarl.parse)

(defun parse-template-string (str &optional (syntax :default))
  (mpc:run (zenekindarl.parser:=template) (zenekindarl.lexer:lex str syntax)))

(defun parse-template-file (file &optional (syntax :default))
  (parse-template-string (read-file-into-string file)  syntax))
