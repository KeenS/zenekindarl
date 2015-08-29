(in-package :cl-user)
(defpackage zenekindarl.lexer
  (:use :cl)
  (:export lex))
(in-package zenekindarl.lexer)

(defgeneric lex (template lexer))
