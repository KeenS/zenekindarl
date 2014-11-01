#|
  This file is a part of clta project.
  Copyright (c) 2014 κeen
|#

(in-package :cl-user)
(defpackage clta.backend
  (:use :cl :clta.util :clta.att)
  (:import-from :alexandria
                :if-let)
  (:export :generate-write-code))
(in-package :clta.backend)

(defgeneric generate-write-code (obj stream-sym)
  (:method (obj stream-sym)
    `(princ ,obj ,stream-sym)))


(defmethod generate-write-code ((obj att-string) stream-sym)
  `(write-sequence ,(value obj) ,stream-sym))

(defmethod generate-write-code ((obj att-octets) stream-sym)
  `(write-sequence ,(value obj) ,stream-sym))

(defmethod generate-write-code ((obj att-variable) stream-sym)
  (ecase (vartype obj)
    ((:string :octets)
     `(write-sequence ,(varsym obj) ,stream-sym))
    (:anything
     `(princ ,(varsym obj) ,stream-sym))))

(defmethod generate-write-code ((obj att-eval) stream-sym)
  (declare (ignore stream-sym))
  (sexp obj))

(defmethod generate-write-code ((obj att-eval-to-output) stream-sym)
  `(princ ,(sexp obj) ,stream-sym))

(defmethod generate-write-code ((obj att-nil) stream-sym)
  nil)

(defmethod generate-write-code ((obj att-progn) stream-sym)
  (cons 'progn (mapcar (lambda (node)
                            (generate-write-code node stream-sym))
                       (nodes obj))))

(defmethod generate-write-code ((obj att-if) stream-sym)
  (with-slots (cond-clause then-clause else-clause) obj
    (list 'if
          (generate-write-code cond-clause stream-sym)
          (generate-write-code then-clause stream-sym)
          (generate-write-code else-clause stream-sym))))

(defmethod generate-write-code ((obj att-loop) stream-sym)
  (with-slots (loop-seq body loop-var) obj
    `(loop
        for ,(or (varsym loop-var) (gensym "loop-var"))
        in ,(sexp loop-seq)
        do ,(generate-write-code body stream-sym))))
