#|
  This file is a part of clta project.
  Copyright (c) 2014 κeen
|#

(in-package :cl-user)
(defpackage clta-bench
  (:use
   :cl
   :clta)
  (:import-from :fast-io
   :with-fast-output))
(in-package :clta-bench)

(defparameter *templates* '(("simple.tmpl" . ())))

(defmacro bench1000000 (title form)
  `(progn
     (write-line ,title)
     (time (loop :repeat 1000000 :do ,form))))

(defun bench/clta (tmpl args)
  (let ((stream-renderer (compile-template-file (make-backend :stream) tmpl ()))
        (octet-stream-renderer (compile-template-file (make-backend :octet-stream) tmpl ()))
        (string-renderer (compile-template-file (make-backend :string) tmpl ()))
        (octets-renderer (compile-template-file (make-backend :octets) tmpl ()))
        (fast-io-renderer (compile-template-file (make-backend :fast-io) tmpl ()))
        (/dev/null (make-broadcast-stream)))
    (bench1000000 (format nil "compiled stream backend with ~a" tmpl)
                  (apply stream-renderer /dev/null args))
    (bench1000000 (format nil "compiled octet stream backend with ~a" tmpl)
                  (apply octet-stream-renderer /dev/null args))
    (bench1000000 (format nil "compiled string backend with ~a" tmpl)
                  (apply string-renderer args))
    (bench1000000 (format nil "compiled octet backend with ~a" tmpl)
                  (apply octets-renderer args))
    (bench1000000 (format nil "compiled fast-io backend with ~a" tmpl)
                  (with-fast-output (buff) (apply fast-io-renderer buff args)))))

(defun bench (tmpl args)
  (bench/clta tmpl args))

(loop :for (tmpl . args) :in *templates*
      :do (bench tmpl args))
