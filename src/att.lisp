#|
  This file is a part of clta project.
  Copyright (c) 2014 κeen
|#

(in-package :cl-user)
(defpackage clta.att
  (:use :cl :clta.util)
  (:export :print-object
           :att-node
           :att-leaf
           :att-control
           
           :att-string
           :att-octets
           :value
           
           :att-variable
           :varsym
           :vartype
           
           :att-eval
           :att-eval-to-output
           :sexp
           
           :att-nil
           
           :att-progn
           :nodes
           
           :att-if
           :cond-clause
           :then-clause
           :else-clause
           
           :att-loop
           :loop-seq
           :loop-var
           :body
           
           :att-include
           :path
           
           :att-equal))
(in-package :clta.att)

;;; Abstract Template Tree
(defclass att-node ()
  ())
(defclass att-leaf (att-node)
  ())
(defclass att-control (att-node)
  ())

(defgeneric att-equal (x y)
  (:method ((x att-node) (y att-node))
    (declare (ignore x y))
    nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; att-string
(defclass att-string (att-leaf)
  ((value
    :type 'string
    :accessor value
    :initarg :value)))

(defmethod print-object ((obj att-string) stream)
  (format stream "#<ATT-STRING ~S>" (value obj)))

(defun att-string (str)
  (make-instance 'att-string :value str))

(defmethod att-equal ((x att-string) (y att-string))
  (string= (value x) (value y)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; att-octets
(defclass att-octets (att-leaf)
  ((value
    :type 'octets
    :accessor value
    :initarg :value)))

(defmethod print-object ((obj att-octets) stream)
  (format stream "#<ATT-OCTETS ~S>" (value obj)))

(defun att-octets (seq)
  (make-instance 'att-octets :value seq))

(defmethod att-equal ((x att-octets) (y att-octets))
  (equalp (value x) (value y)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; att-variable
(defclass att-variable (att-leaf)
  ((varsym
    :type 'symbol
    :accessor varsym
    :initarg :varsym)
   (vartype
    :type '(or :string :octets :anything)
    :accessor vartype
    :initarg :vartype
    :initform :anything)))

(defmethod print-object ((obj att-variable) stream)
  (format stream "#<ATT-VARIABLE ~S>" (varsym obj)))

(defun att-variable (sym &optional (type :anything))
  (make-instance 'att-variable
                 :varsym sym
                 :vartype type))

(defmethod att-equal ((x att-variable) (y att-variable))
  (and (eql (varsym x)  (varsym y))
       (eql (vartype x) (vartype y))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; att-eval
(defclass att-eval (att-leaf)
  ((sexp
    :accessor sexp
    :initarg :sexp)))

(defmethod print-object ((obj att-eval) stream)
  (format stream "#<ATT-EVAL ~S>" (sexp obj)))

(defun att-eval (sexp)
  (make-instance 'att-eval :sexp sexp))

(defmethod att-equal ((x att-eval) (y att-eval))
  (equalp (sexp x) (sexp y)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; att-eval-to-output
(defclass att-eval-to-output (att-leaf)
  ((sexp
    :accessor sexp
    :initarg :sexp)))

(defmethod print-object ((obj att-eval-to-output) stream)
  (format stream "#<ATT-EVAL ~S>" (sexp obj)))

(defun att-eval-to-output (sexp)
  (make-instance 'att-eval-to-output :sexp sexp))

(defmethod att-equal ((x att-eval-to-output) (y att-eval-to-output))
  (equalp (sexp x) (sexp y)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; att-nil
(defclass att-nil (att-leaf)
  ())

(defun att-nil ()
  (make-instance 'att-nil))

(defmethod att-equal ((x att-nil) (y att-nil))
  t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; att-progn
(defclass att-progn (att-control)
  ((nodes
    :type 'list
    :accessor nodes
    :initarg :nodes)))

(defmethod print-object ((obj att-progn) stream)
  (format stream "#<ATT-PROGN ~{~S~^ ~}>" (nodes obj)))

(defun att-progn (&rest nodes)
  (make-instance 'att-progn
                 :nodes nodes))

(defmethod att-equal ((x att-progn) (y att-progn))
  (loop
     :for a :in (nodes x)
     :for b :in (nodes y)
     :always (att-equal a b)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; att-if
(defclass att-if (att-control)
  ((cond-clause
    :accessor cond-clause
    :initarg :cond)
   (then-clause
    :type 'att-node
    :accessor then-clause
    :initarg :then)
   (else-clause
    :type 'att-node
    :accessor else-clause
    :initarg :else
    :initform (att-nil))))

(defmethod print-object ((obj att-if) stream)
  (with-slots (cond-clause then-clause else-clause) obj
    (format stream "#<ATT-IF ~S :THEN ~S :ELSE ~S>" cond-clause then-clause else-clause)))

(defun att-if (cond-clause then-clause &optional (else-clause (att-nil)))
  (make-instance 'att-if
                 :cond cond-clause
                 :then then-clause
                 :else else-clause))

(defmethod att-equal ((x att-if) (y att-if))
  (and (att-equal (cond-clause x)
                  (cond-clause y))
       (att-equal (then-clause x)
                  (then-clause y))
       (att-equal (else-clause x)
                  (else-clause y))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; att-loop
(defclass att-loop (att-control)
  ((loop-seq
      :type 'att-leaf
      :accessor loop-seq
      :initarg :loop-seq)
   (loop-var
      :type 'att-variable
      :accessor loop-var
      :initarg :loop-var)
   (body
    :type 'att-node
    :accessor body
    :initarg :body)))

(defmethod print-object ((obj att-loop) stream)
  (with-slots (loop-seq loop-var body) obj
    (if loop-var
        (format stream "#<ATT-LOOP ~s IN ~s ~s>" loop-var loop-seq body)
        (format stream "#<ATT-LOOP ~s ~s>" loop-seq body))))

(defun att-loop (loop-seq body &optional (loop-var (att-variable (gensym "loopvar"))))
  (make-instance 'att-loop
                 :loop-seq loop-seq
                 :body body
                 :loop-var loop-var))

(defmethod att-equal ((x att-loop) (y att-loop))
  (and (att-equal (loop-seq x)
                  (loop-seq y))
       (att-equal (loop-var x)
                  (loop-var y))
       (att-equal (body x)
                  (body y))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; att-include
(defclass att-include (att-control)
  ((path
    :initarg :path
    :accessor path)))

(defmethod print-object ((obj att-include) stream)
  (format stream "#<ATT-INCLUDE ~S>" (slot-value obj 'path)))

(defun att-include (path)
  (make-instance 'att-include :path path))

(defmethod att-equal ((x att-include) (y att-include))
  ;; :FIXME: treat relative and absolute pathes
  (string= (path x) (path y)))
