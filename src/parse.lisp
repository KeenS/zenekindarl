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
  (maxpc:parse (zenekindarl.lexer:lex str syntax) (zenekindarl.parser:=template)))

(defun parse-template-file (file &optional (syntax :default))
  (with-open-file (f file)
   (parse-template-string f  syntax)))
