(in-package :cl-user)
(defpackage arrows.parse
  (:use :cl
        :arrows.att
        :arrows.lexer
        :arrows.lexer.default
        :arrows.parser)
  (:import-from :alexandria
                :read-file-into-string)
  (:export :parse-template-string
           :parse-template-file))
(in-package arrows.parse)

(defun parse-template-string (str)
  (mpc:run (arrows.parser:=template) (arrows.lexer.default:lex str)))

(defun parse-template-file (file)
  (parse-template-string (read-file-into-string file)))
