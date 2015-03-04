#|
  This file is a part of arrows project.
  Copyright (c) 2014 κeen
|#

(in-package :cl-user)
(defpackage arrows.backend.sequence
  (:use :cl :arrows.util :arrows.att :arrows.backend :arrows.backend.stream)
  (:import-from :fast-io
   :with-fast-output
                :fast-write-sequence)
  (:import-from :babel
                :string-to-octets)
  (:export :string-backend
           :octet-backend))
(in-package :arrows.backend.sequence)

(defclass string-backend (stream-backend)
  ((string
    :accessor string-of
    :initarg :string)))

(defmethod make-backend ((backend (eql :string)) &key string &allow-other-keys)
  (make-instance 'string-backend
                 :string string))

(defmethod emit-lambda ((backend string-backend) att)
  (let* ((code (emit-code backend att)))
    (eval
     `(lambda ,(emit-parameters backend)
        (with-output-to-string (,(stream-of backend) ,(string-of backend))
          ,code)))))


(defclass octet-backend (string-backend octet-stream-backend)
  ((buffer%
    :accessor buffer-of
    :initform (gensym "buffer"))))

(defmethod make-backend ((backend (eql :octets)) &key &allow-other-keys)
  (make-instance 'octet-backend))

(defmethod emit-code ((backend octet-backend) (obj att-output) &key output-p)
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
                `(fast-write-sequence (string-to-octets (let ((val ,(emit-code backend arg :output-p t)))
                                                          (if (stringp val)
                                                              val
                                                              (princ-to-string val))))
                                      ,buffer%)))))
        (att-leaf
         (if (auto-escape arg)
             `(fast-write-sequence (string-to-octets ,(emit-code backend arg :output-p t)) ,buffer%)
             `(fast-write-sequence (string-to-octets (let ((val ,(emit-code backend arg :output-p t)))
                                                       (if (stringp val)
                                                           val
                                                           (princ-to-string val))))
                                   ,buffer%)))
        (t (call-next-method))))))

(defmethod emit-lambda ((backend octet-backend) att)
  (let* ((code (emit-code backend att)))
    (eval
     `(lambda ,(emit-parameters backend)
        (with-fast-output (,(buffer-of backend))
          ,code)))))
