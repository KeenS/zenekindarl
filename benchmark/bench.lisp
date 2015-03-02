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

(defparameter *templates* '("simple.tmpl"))

(defmacro bench1000000 (form)
  `(time (loop :repeat 1000000 :do ,form)))

(defun bench/clta (tmpl)
  (let ((stream-renderer (compile-template-file (make-backend :stream) tmpl ()))
        (octet-stream-renderer (compile-template-file (make-backend :octet-stream) tmpl ()))
        (string-renderer (compile-template-file (make-backend :string) tmpl ()))
        (octets-renderer (compile-template-file (make-backend :octets) tmpl ()))
        (fast-io-renderer (compile-template-file (make-backend :fast-io) tmpl ()))
        (/dev/null (make-broadcast-stream)))
    (bench1000000 (funcall stream-renderer /dev/null))
    (bench1000000 (funcall octet-stream-renderer /dev/null))
    (bench1000000 (funcall string-renderer))
    (bench1000000 (funcall octets-renderer))
    (bench1000000 (with-fast-output (buff) (funcall fast-io-renderer buff)))))

(defun bench (tmpl)
  (bench/clta tmpl))

(loop :for tmpl :in *templates*
      :do (bench tmpl))
