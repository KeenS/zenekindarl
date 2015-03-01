#|
  This file is a part of clta project.
  Copyright (c) 2014 κeen
|#

(in-package :cl-user)
(defpackage clta.pass
  (:use :cl :clta.util :clta.att)
  (:import-from :alexandria
                :if-let)
  (:import-from :optima
                :match)
  (:export :*optimizing-passes*
           :*necesarry-passes*
           :apply-passes
           :flatten-pass
           :fold-variables-pass
           :append-sequence-pass
           :remove-progn-pass))
(in-package :clta.pass)

(defgeneric traverse-node (func obj)
  (:method (func (obj att-progn))
    (funcall func
             (apply #'att-progn
                    (mapcar (lambda (node)
                              (traverse-node func node))
                            (nodes obj)))))
  (:method (func (obj att-if))
    (funcall func
             (att-if
              (traverse-node func (cond-clause obj))
              (traverse-node func (then-clause obj))
              (traverse-node func (else-clause obj)))))
  (:method (func (obj att-output))
    (funcall func (att-output (traverse-node func (arg obj)))))
  (:method (func (obj att-loop))
    (funcall func
             (att-loop
              (traverse-node func (loop-seq obj))
              (traverse-node func (body obj))
              (traverse-node func (loop-var obj)))))
  (:method (func (obj att-node))
    (funcall func obj)))

(defgeneric append-att-node-aux (x y)
  (:method ((x att-progn) (y att-progn))
    (apply #'att-progn (append (nodes x) (nodes y))))
  (:method ((x att-string) (y att-string))
    (att-string (concatenate 'string (value x) (value y))))
  (:method ((x att-output) (y att-output))
    (apply #'values (mapcar #'att-output (multiple-value-list (append-att-node-aux (arg x) (arg y))))))
  (:method ((x att-nil) (y att-nil))
    (declare (ignore x y))
    (values))
  (:method ((x att-nil) y)
    (declare (ignore x))
    y)
  (:method (x (y att-nil))
    (declare (ignore y))
    x)
  (:method ((x att-node) (y att-node))
    (values x y)))

(defun append-att-node (&rest args)
  (nreverse
   (reduce (lambda (acc y)
             (revappend
              (multiple-value-list (append-att-node-aux (car acc) y))
              (cdr acc)))
           args :initial-value (list (att-nil)))))

(defgeneric flatten-impl (obj)
  (:method ((obj att-progn))
    ;; the appended att nodes should be (#<ATT-PROGN ..>)
    (car (apply #'append-att-node (nodes obj))))
  (:method ((obj att-node))
    (att-progn obj)))

(defun flatten-pass (obj env)
  (declare (ignore env))
  (traverse-node #'flatten-impl obj))

(defgeneric remove-progn-impl (obj)
  (:method ((obj att-progn))
    (match (nodes obj)
      (() (att-nil))
      ((list x) x)
      (xs (apply #'att-progn xs))))
  (:method ((obj att-node))
    obj))

(defun remove-progn-pass (obj env)
  (declare (ignore env))
  (traverse-node #'remove-progn-impl obj))

(defgeneric fold-variables-impl (obj vars)
  (:method ((obj att-variable) vars)
    (if-let ((value (getf vars (intern (symbol-name (varsym obj)) :keyword))))
      (ecase (vartype obj)
        (:string
         (att-string value))
        (:anything
         (att-string (format nil "~A" value))))
      obj))
  (:method ((obj att-node) vars)
    (declare (ignore vars))
    obj))

(defun fold-variables-pass (obj env)
  (traverse-node (lambda (o) (fold-variables-impl o (getf env :known-args))) obj))

(defgeneric append-sequence-impl (obj)
  (:method ((obj att-progn))
    (apply #'att-progn (apply #'append-att-node (nodes obj))))
  (:method ((obj att-node))
    obj))

(defun append-sequence-pass (obj env)
  (declare (ignore env))
  (traverse-node #'append-sequence-impl obj))

(defparameter *optimizing-passes* (list #'fold-variables-pass #'flatten-pass #'remove-progn-pass #'append-sequence-pass))
(defparameter *necessary-passes* ())

(defun apply-passes (att env)
  (reduce (lambda (att pass)
            (funcall pass att env))
          (append *default-passes* *necessary-passes*)
          :initial-value att))
