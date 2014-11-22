#|
  This file is a part of clta project.
  Copyright (c) 2014 κeen
|#

(in-package :cl-user)
(defpackage clta.backend.stream
  (:use :cl :clta.util :clta.att :clta.backend)
  (:import-from :babel
                :string-to-octets)
  (:export :stream-backend
           :octet-stream-backend
           :stream-of))
(in-package :clta.backend.stream)

(defclass stream-backend (backend)
  ((stream%
    :accessor stream-of
    :initarg :stream)))

(defmethod emit-code ((backend stream-backend) (obj att-output))
  (with-slots (exp) obj
    (with-slots (stream%) backend
      (typecase exp
        (att-string
         `(write-sequence ,(emit-code backend exp) ,stream%))
        (att-variable
         (case (vartype exp)
           (:string
            `(write-sequence ,(emit-code backend exp) ,stream%))
           (:anything
            `(princ ,(emit-code backend exp) ,stream%))))
        (att-leaf
         `(princ ,(emit-code backend exp) ,stream%))
        (t (call-next-method))))))


(defclass octet-stream-backend (stream-backend)
  ())

(defmethod emit-code ((backend octet-stream-backend) (obj att-string))
  (string-to-octets (value obj)))

(defmethod emit-code ((backend octet-stream-backend) (obj att-output))
  (with-slots (exp) obj
    (if (and (typep exp 'att-variable)
             (eq (vartype exp) :string))
        `(write-sequence ,(string-to-octets (varsym exp)) ,(stream-of backend))
        (call-next-method))))
