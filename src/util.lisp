(in-package :cl-user)
(defpackage zenekindarl.util
  (:use :cl)
  (:export :octets
           :collect-hash-value))
(in-package :zenekindarl.util)

(deftype octets ()
  '(simple-array (unsigned-byte 8) (*)))

(defun octets (&rest contents)
  (make-array (length contents)
              :element-type '(unsigned-byte 8)
              :initial-contents contents))

(defun collect-hash-key (func hash)
  (loop
     :for key :being :the :hash-keys :of hash
     :collect (funcall func key)))


(defun collect-hash-value (func hash)
  (loop
     :for value :being :the :hash-values :of hash
     :collect (funcall func value)))
