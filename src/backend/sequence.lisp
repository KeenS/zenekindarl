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
  (:import-from :big-string
                :make-big-string
                :string-of-big-string
                :big-string-append
                )
  (:export :string-backend
           :octet-backend))
(in-package :arrows.backend.sequence)

(defclass string-backend (backend)
  ((big-string%
    :reader big-string-of
    :initform (gensym "big-string"))))

(defmethod make-backend ((backend (eql :string)) &key &allow-other-keys)
  (make-instance 'string-backend))

(defmethod emit-lambda ((backend string-backend) att)
  (let* ((code (emit-code backend att)))
    (eval
     `(lambda ,(emit-parameters backend)
        (let ((,(big-string-of backend) (make-big-string)))
          ,code
          (string-of-big-string ,(big-string-of backend)))))))

(defmethod emit-code ((backend string-backend) (obj att-output) &key output-p)
  (declare (ignore output-p))
  (with-slots (arg) obj
    (with-slots (big-string%) backend
      (typecase arg
        (att-string
         `(big-string-append ,big-string% ,(emit-code backend arg :output-p t)))
        (att-variable
         (case (vartype arg)
           (:string
            `(big-string-append ,big-string% ,(emit-code backend arg :output-p t)))
           (:anything
            (if (auto-escape arg)
                `(big-string-append ,big-string% ,(emit-code backend arg :output-p t))
                `(big-string-append ,big-string% (princ-to-string ,(emit-code backend arg :output-p t)))))))
        (att-leaf
         (if (auto-escape arg)
             `(big-string-append ,big-string% ,(emit-code backend arg :output-p t))
             `(big-string-append ,big-string% (princ-to-string ,(emit-code backend arg :output-p t)))))
        (t (call-next-method))))))

(defclass octet-backend (backend)
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
