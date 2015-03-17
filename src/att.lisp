#|
This file is a part of arrows project.
Copyright (c) 2014 κeen
|#

(in-package :cl-user)
(defpackage arrows.att
  (:use :cl :arrows.util)
  (:export :print-object
           :att-node
           :att-leaf
           :auto-escape
           :att-control
           
           :att-string
           :value
           
           :att-variable
           :varsym
           :vartype

           :att-gensym
           :gensym-string
           
           :att-eval
           :sexp
           
           :att-output
           :arg

           :att-constant
           
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
(in-package :arrows.att)

;;; Abstract Template Tree
(defclass att-node ()
  ())
(defclass att-leaf (att-node)
  ((auto-escape
    :type '(or null t)
    :accessor auto-escape
    :initarg :auto-escape
    :initform t)))
(defclass att-control (att-node)
  ())

(defgeneric att-equal (x y)
  (:method (x y)
    (declare (ignore x y))
    nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; att-string
(defclass att-string (att-leaf)
  ((value
    :type 'string
    :accessor value
    :initarg :value)
   (auto-escape
    :initform nil)))

(defmethod print-object ((obj att-string) stream)
  (format stream "#<ATT-STRING ~S>" (value obj)))

(defun att-string (str)
  (make-instance 'att-string :value str))

(defmethod att-equal ((x att-string) (y att-string))
  (string= (value x) (value y)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; att-variable
(defclass att-variable (att-leaf)
  ((varsym
    :type 'symbol
    :accessor varsym
    :initarg :varsym)
   (vartype
    :type '(or :string :anything)
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
;;; att-gensym
(defclass att-gensym (att-variable)
  ((gensym-string
    :type '(or null string)
    :accessor gensym-string
    :initarg :gensym-string)))

(defmethod print-object ((obj att-gensym) stream)
  (format stream "#<ATT-GENSYM ~S>" (gensym-string obj)))

(defun att-gensym (gensym-string &optional (type :anything))
  (make-instance 'att-gensym
                 :varsym (gensym gensym-string)
                 :vartype type
                 :gensym-string gensym-string))

(defmethod att-equal ((x att-gensym) (y att-gensym))
  (and (string= (gensym-string x)  (gensym-string y))
       (eql (vartype x) (vartype y))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; att-constant
(defclass att-constant (att-leaf)
  ((value
    :accessor value
    :initarg :value)
   (auto-escape
    :initform nil)))

(defmethod print-object ((obj att-constant) stream)
  (format stream "#<ATT-CONSTANT ~S>" (value obj)))

(defun att-constant (val)
  (make-instance 'att-constant
                 :value val))

(defmethod att-equal ((x att-constant) (y att-constant))
  (equal (value x) (value y)))


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
;;; att-nil
(defclass att-nil (att-leaf)
  ())

(defun att-nil ()
  (make-instance 'att-nil))

(defmethod att-equal ((x att-nil) (y att-nil))
  t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; att-eval-to-output
(defclass att-output (att-control)
  ((arg
    :accessor arg
    :initarg :arg)))

(defmethod print-object ((obj att-output) stream)
  (format stream "#<ATT-OUTPUT ~S>" (arg obj)))

(defun att-output (arg)
  (make-instance 'att-output :arg arg))

(defmethod att-equal ((x att-output) (y att-output))
  (att-equal (arg x) (arg y)))



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

(defun att-loop (loop-seq body &optional (loop-var (att-gensym "loopvar")))
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
