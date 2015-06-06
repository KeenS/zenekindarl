(in-package :cl-user)
(defpackage arrows.lexer
  (:use :cl)
  (:export lex))
(in-package arrows.lexer)

(defgeneric lex (template lexer))
