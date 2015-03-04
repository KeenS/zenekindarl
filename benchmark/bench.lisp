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
   :with-fast-output)
  (:import-from :alexandria
                :make-keyword))
(in-package :arrows-bench)

(defparameter *templates* `(("simple.tmpl" . ())
                            ("1var.tmpl" . (:name "κeen"))
                            ("100var.tmpl" . ,(loop :for i :from 1 :to 100
                                                    :append (list (make-keyword (format nil "FOO~a" i)) (format nil "bar~a" i))))))

(defmacro bench10000 (title form)
  `(progn
     (write-line ,title)
     (time (loop :repeat 10000 :do ,form))))

(defmacro bench/arrows (tmpl args)
  (let ((stream-renderer (compile-template-file :stream tmpl ()))
        (octet-stream-renderer (compile-template-file :octet-stream tmpl ()))
        (string-renderer (compile-template-file :string tmpl ()))
        (octets-renderer (compile-template-file :octets tmpl ()))
        (fast-io-renderer (compile-template-file :fast-io tmpl ())))
    `(progn
      (with-open-file (/dev/null "/dev/null" :direction :output :if-exists :append)
        (bench10000 (format nil "compiled stream backend with ~a" ,tmpl)
                      (funcall ,stream-renderer /dev/null ,@args))
        (bench10000 (format nil "compiled string backend with ~a" ,tmpl)
                      (write-string (funcall ,string-renderer ,@args) /dev/null)))
      (with-open-file (/dev/null "/dev/null" :element-type '(unsigned-byte 8) :direction :output :if-exists :append)
        (bench10000 (format nil "compiled octet stream backend with ~a" ,tmpl)
                      (funcall  ,octet-stream-renderer /dev/null ,@args))
        (bench10000 (format nil "compiled octet backend with ~a" ,tmpl)
                      (write-sequence (funcall ,octets-renderer ,@args) /dev/null))
        (bench10000 (format nil "compiled fast-io backend with ~a" ,tmpl)
                      (with-fast-output (buff /dev/null) (funcall ,fast-io-renderer buff ,@args)))))))

(defmacro bench (tmpl args)
  `(bench/arrows ,tmpl ,args))

#.`(progn
    ,@(loop :for (tmpl . args) :in *templates*
          :collect `(bench ,tmpl ,args)))
