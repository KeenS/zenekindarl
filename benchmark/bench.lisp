#|
This file is a part of arrows project.
Copyright (c) 2014 κeen
|#


;;; To run benchmark, simply cd to here and load this file.
(in-package :cl-user)
(defpackage arrows-bench
  (:use
   :cl
   :arrows)
  (:import-from :fast-io
   :with-fast-output))
(in-package :arrows-bench)

(defparameter *templates* '(("simple.tmpl" . ())))

(defmacro bench1000000 (title form)
  `(progn
     (write-line ,title)
     (time (loop :repeat 1000000 :do ,form))))

(defun bench/arrows (tmpl args)
  (let ((stream-renderer (compile-template-file (make-backend :stream) tmpl ()))
        (octet-stream-renderer (compile-template-file (make-backend :octet-stream) tmpl ()))
        (string-renderer (compile-template-file (make-backend :string) tmpl ()))
        (octets-renderer (compile-template-file (make-backend :octets) tmpl ()))
        (fast-io-renderer (compile-template-file (make-backend :fast-io) tmpl ())))
    (with-open-file (/dev/null "/dev/null" :direction :output :if-exists :append)
      (bench1000000 (format nil "compiled stream backend with ~a" tmpl)
                    (apply stream-renderer /dev/null args))
      (bench1000000 (format nil "compiled string backend with ~a" tmpl)
                    (write-string (apply string-renderer args) /dev/null)))
    (with-open-file (/dev/null "/dev/null" :element-type '(unsigned-byte 8) :direction :output :if-exists :append)
      (bench1000000 (format nil "compiled octet stream backend with ~a" tmpl)
                    (apply octet-stream-renderer /dev/null args))
      (bench1000000 (format nil "compiled octet backend with ~a" tmpl)
                    (write-sequence (apply octets-renderer args) /dev/null))
      (bench1000000 (format nil "compiled fast-io backend with ~a" tmpl)
                    (with-fast-output (buff /dev/null) (apply fast-io-renderer buff args))))))

(defun bench (tmpl args)
  (bench/arrows tmpl args))

(loop :for (tmpl . args) :in *templates*
      :do (bench tmpl args))
