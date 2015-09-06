#|
This file is a part of zenekindarl project.
Copyright (c) 2014 κeen
|#


;;; To run benchmark, simply cd to here and load this file.
(require 'asdf)
(require 'zenekindarl)
(require 'html-template)
(in-package :cl-user)
(defpackage zenekindarl-bench
  (:use
   :cl
   :zenekindarl

   :html-template)
  (:import-from :fast-io
                :with-fast-output)
  (:import-from :alexandria
                :make-keyword))
(in-package :zenekindarl-bench)

(defparameter *templates* `(("simple.tmpl" . ())
                            ("1var.tmpl" . (:name "κeen"))
                            ("100var.tmpl" . ,(loop :for i :from 1 :to 100
                                                 :append (list (make-keyword (format nil "FOO~a" i)) (format nil "bar~a" i))))
                            ("repeat.tmpl" . (:foos ',(loop :for i :from 1 :to 100
                                                         :collect (format nil "foo~a" i))))))


(defmacro bench10000 (title form)
  `(progn
     (write-line ,title)
     (time (loop :repeat 10000 :do ,form))))

(defmacro bench/zenekindarl (tmpl args)
  (let* ((tmpl (pathname (concatenate 'string tmpl ".zenekindarl")))
         (stream-renderer       (compile-template-file :stream tmpl))
         (octet-stream-renderer (compile-template-file :octet-stream tmpl))
         (string-renderer       (compile-template-file :string tmpl))
         (octets-renderer       (compile-template-file :octets tmpl))
         (fast-io-renderer      (compile-template-file :fast-io tmpl)))
    `(progn
       (write-line "zenekindarl")
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

(defmacro bench/html-template (tmpl args)
  (let* ((args           (if (string= tmpl "repeat.tmpl")
                             (list :foos (mapcar (lambda (x) (list :foo x)) (cadadr args)))
                             args))
         (tmpl (pathname (concatenate 'string tmpl ".html-template")))
         (renderer       (create-template-printer tmpl)))
    `(progn
       (write-line "html-template")
       (with-open-file (/dev/null "/dev/null" :direction :output :if-exists :append)
         (let ((*default-template-output* /dev/null))
          (bench10000 (format nil "render ~a" ,tmpl)
                      (fill-and-print-template ,renderer ',args)))))))

(defmacro bench (tmpl args)
  `(progn
     (bench/zenekindarl ,tmpl ,args)
     (bench/html-template ,tmpl ,args)))

#.`(progn
     ,@(loop :for (tmpl . args) :in *templates*
          :collect `(bench ,tmpl ,args)))
