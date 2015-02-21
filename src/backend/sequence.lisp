#|
  This file is a part of clta project.
  Copyright (c) 2014 κeen
|#

(in-package :cl-user)
(defpackage clta.backend.sequence
  (:use :cl :clta.util :clta.att :clta.backend :clta.backend.stream)
  (:export :string-backend
           :octet-backend))
(in-package :clta.backend.sequence)

(defclass string-backend (stream-backend)
  ((string
    :accessor string-of
    :initarg :string)))

(defmethod make-backend ((backend (eql :string)) &key string &allow-other-keys)
  (make-instance 'string-backend
                 :stream (gensym "stream")
                 :string string))

(defmethod emit-lambda ((backend string-backend) att)
  (let* ((code (emit-code backend att))
         (syms (symbols backend)))
    (eval
     `(lambda ,(if syms `(&key ,@syms) ())
        (with-output-to-string (,(stream-of backend) ,(string-of backend))
          ,code)))))


(defclass octet-backend (string-backend octet-stream-backend)
  ())

(defmethod make-backend ((backend (eql :octet)) &key string &allow-other-keys)
  (make-instance 'octet-backend
                 :stream (gensym "stream")
                 :string string))
