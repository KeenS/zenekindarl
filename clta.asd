#|
  This file is a part of clta project.
  Copyright (c) 2014 κeen
|#

#|
  Author: κeen
|#

(in-package :cl-user)
(defpackage clta-asd
  (:use :cl :asdf))
(in-package :clta-asd)

(defsystem clta
  :version "0.1"
  :author "κeen"
  :license ""
  :depends-on (:alexandria :babel :optima :cl-ppcre)
  :components ((:module "src"
                :components
                ((:file "clta")
                 (:file "att" :depends-on ("util"))
                 (:file "backend" :depends-on ("util" "att"))
                 (:file "pass" :depends-on ("util"))
                 (:file "parse")
                 (:file "util"))))
  :description ""
  :long-description
  #.(with-open-file (stream (merge-pathnames
                             #p"README.markdown"
                             (or *load-pathname* *compile-file-pathname*))
                            :if-does-not-exist nil
                            :direction :input)
      (when stream
        (let ((seq (make-array (file-length stream)
                               :element-type 'character
                               :fill-pointer t)))
          (setf (fill-pointer seq) (read-sequence seq stream))
          seq)))
  :in-order-to ((test-op (test-op clta-test))))
