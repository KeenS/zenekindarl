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
  :depends-on (
               :alexandria
               :anaphora
               :babel
               :optima
               :cl-ppcre
               :esrap
               :html-encode
               :fast-io
               )
  :components ((:module "src"
                :components
                ((:file "clta" :depends-on ("parse" "pass" "backend" "be"))
                 (:file "att" :depends-on ("util"))
                 (:file "backend" :depends-on ("util" "att"))
                 (:module "be"
                          :pathname "backend"
                          :depends-on ("backend")
                  :components ((:file "stream")
                               (:file "sequence" :depends-on ("stream"))))
                 (:file "pass" :depends-on ("util" "att"))
                 (:file "parse" :depends-on ("att" "st"))
                 (:file "syntax-table")
                 (:module "st"
                          :pathname "syntax-table"
                          :depends-on ("syntax-table")
                          :components ((:file "default")))
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
