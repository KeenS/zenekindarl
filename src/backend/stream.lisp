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

(defmethod make-backend ((backend (eql :stream)) &key stream &allow-other-keys)
  (make-instance 'stream-backend :stream stream))

(defmethod emit-code ((backend stream-backend) (obj att-output) &key output-p)
  (with-slots (arg) obj
    (with-slots (stream%) backend
      (typecase arg
        (att-string
         `(write-sequence ,(emit-code backend arg :output-p t) ,stream%))
        (att-variable
         (case (vartype arg)
           (:string
            `(write-sequence ,(emit-code backend arg :output-p t) ,stream%))
           (:anything
            (if (auto-escape arg)
                `(write-sequence ,(emit-code backend arg :output-p t) ,stream%)
                `(princ ,(emit-code backend arg :output-p t) ,stream%)))))
        (att-leaf
         (if (auto-escape arg)
             `(write-sequence ,(emit-code backend arg :output-p t) ,stream%)
             `(princ ,(emit-code backend arg :output-p t) ,stream%)))
        (t (call-next-method))))))


(defclass octet-stream-backend (stream-backend)
  ())

(defmethod make-backend ((backend (eql :octet-stream)) &key stream &allow-other-keys)
  (make-instance 'stream-backend :stream stream))

(defmethod emit-code ((backend octet-stream-backend) (obj att-string) &key output-p)
  (string-to-octets (value obj)))

(defmethod emit-code ((backend octet-stream-backend) (obj att-output) &key output-p)
  (with-slots (arg) obj
    (if (and (typep arg 'att-variable)
             (eq (vartype arg) :string))
        `(write-sequence ,(string-to-octets (varsym arg)) ,(stream-of backend))
        (call-next-method))))
