#|
  This file is a part of arrows project.
  Copyright (c) 2014 κeen
|#

(in-package :cl-user)
(defpackage arrows.backend.stream
  (:use :cl :arrows.util :arrows.att :arrows.backend)
  (:import-from :babel
                :string-to-octets)
  (:import-from :fast-io
   :with-fast-output
                :fast-write-sequence)
  (:export :stream-backend
           :octet-stream-backend
           :stream-of
           :buffer-of))
(in-package :arrows.backend.stream)

(defclass stream-backend (backend)
  ((stream%
    :accessor stream-of
    :initarg :stream
    :initform (gensym "stream"))))

(defmethod make-backend ((backend (eql :stream)) &key &allow-other-keys)
  (make-instance 'stream-backend))

(defmethod emit-code ((backend stream-backend) (obj att-output) &key output-p)
  (declare (ignore output-p))
  (with-slots (arg) obj
    (with-slots (stream%) backend
      (typecase arg
        (att-string
         `(write-string ,(emit-code backend arg :output-p t) ,stream%))
        (att-variable
         (case (vartype arg)
           (:string
            `(write-string ,(emit-code backend arg :output-p t) ,stream%))
           (:anything
            (if (auto-escape arg)
                `(write-string ,(emit-code backend arg :output-p t) ,stream%)
                `(princ ,(emit-code backend arg :output-p t) ,stream%)))))
        (att-leaf
         (if (auto-escape arg)
             `(write-string ,(emit-code backend arg :output-p t) ,stream%)
             `(princ ,(emit-code backend arg :output-p t) ,stream%)))
        (t (call-next-method))))))

(defmethod emit-lambda ((backend stream-backend) att)
  (let* ((code (emit-code backend att)))
    (eval
     `(lambda ,(cons (stream-of backend) (emit-parameters backend))
        ,code
        t))))


(defclass octet-stream-backend (stream-backend)
  ((buffer%
    :accessor buffer-of
    :initform (gensym "buffer"))))

(defmethod make-backend ((backend (eql :octet-stream)) &key &allow-other-keys)
  (make-instance 'octet-stream-backend))


(defmethod emit-lambda ((backend octet-stream-backend) att)
  (let* ((code (emit-code backend att))
         (syms (symbols backend)))
    (eval
     `(lambda ,(cons (stream-of backend) (emit-parameters backend))
        (with-fast-output (,(buffer-of backend) ,(stream-of backend))
          ,code)))))

(defmethod emit-code ((backend octet-stream-backend) (obj att-output) &key output-p)
  (declare (ignore output-p))
  (with-slots (arg) obj
    (with-slots (buffer%) backend
      (typecase arg
        (att-string
         `(fast-write-sequence ,(string-to-octets (emit-code backend arg :output-p t)) ,buffer%))
        (att-variable
         (case (vartype arg)
           (:string
            `(fast-write-sequence (string-to-octets ,(emit-code backend arg :output-p t)) ,buffer%))
           (:anything
            (if (auto-escape arg)
                `(fast-write-sequence (string-to-octets ,(emit-code backend arg :output-p t)) ,buffer%)
                `(fast-write-sequence (string-to-octets (princ-to-string ,(emit-code backend arg :output-p t))) ,buffer%)))))
        (att-leaf
         (if (auto-escape arg)
             `(fast-write-sequence (string-to-octets ,(emit-code backend arg :output-p t)) ,buffer%)
             `(fast-write-sequence (string-to-octets (princ-to-string ,(emit-code backend arg :output-p t))) ,buffer%)))
        (t (call-next-method))))))
