(in-package :cl-user)
(defpackage arrows.parse
  (:use :cl
        :arrows.att
        :arrows.lexer
        :arrows.parser)
  (:import-from :alexandria
                :read-file-into-string)
  (:export :parse-template-string
           :parse-template-file))
(in-package arrows.parse)

(defun parse-template-string (str &optional (syntax :default))
  (mpc:run (arrows.parser:=template) (arrows.lexer:lex str syntax)))

(defun parse-template-file (file &optional (syntax :default))
  (parse-template-string (read-file-into-string file)  syntax))
