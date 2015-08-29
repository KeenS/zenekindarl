(in-package :cl-user)
(defpackage zenekindarl.util
  (:use :cl)
  (:export :octets))
(in-package :zenekindarl.util)

(deftype octets ()
  '(simple-array (unsigned-byte 8) (*)))

(defun octets (&rest contents)
  (make-array (length contents)
              :element-type '(unsigned-byte 8)
              :initial-contents contents))

