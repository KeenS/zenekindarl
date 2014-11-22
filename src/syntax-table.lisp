(in-package :cl-user)
(defpackage clta.syntax-table
  (:use :cl
        :esrap        
        :clta.util
        :clta.att)
  (:import-from :alexandria
                :maphash-values)
  (:export :default
           :white-space
           :white-spaces
           :template-string
           :control
           :defmarkers
           :defcontrol
           :defop
           :*markers*
           :*controls*))
(in-package clta.syntax-table)

(defrule white-space
    (or #\Space #\Tab #\Newline #\Return)
  (:constant nil))

(defrule white-spaces
    (+ white-space)
  (:constant nil))

(defclass syntax-table ()
  ((controls :initform ())
   (markers :initform ())
   (rules :initform (make-hash-table))))

(defparameter *controls* ())
(defparameter *markers* (make-hash-table))

(defmacro defmarkers (name open close)
  (setf (gethash name *markers*) (cons open close))
  `(progn
     (defrule template-string
         (+ (not (or ,@(collect-hash-value #'car
                                           *markers*))))
       (:text t)
       (:lambda (s)
         (att-output (att-string s))))))

(defmacro defcontrol (name &body body)
  (pushnew name *controls*)
  `(progn
     (defrule ,name
         ,@body)
     ;; you can overwrite rules anytimes
     (defrule control
         (or ,@*controls*))))

(defmacro defop (name pattern &key transform (markers '(default)))
  (let* ((markers (loop :for marker :in markers
                     :collect (gethash marker *markers*))))
    `(progn
       ,@(loop :for (open-marker . close-marker) :in markers
          :collect
          `(defrule ,name
            (and ,open-marker
                 (? white-spaces)
                 ,pattern
                 (? white-spaces)
                 ,close-marker)
          (:function third)
          ,@(if transform
                `((:around ()
                           (apply ,transform (call-transform))))
                ()))))))
