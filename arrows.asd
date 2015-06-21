#|
  This file is a part of arrows project.
  Copyright (c) 2014 κeen
|#

#|
  Author: κeen
|#

(in-package :cl-user)
(defpackage arrows-asd
  (:use :cl :asdf))
(in-package :arrows-asd)

(defsystem arrows
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
               :mpc
               :cl-annot
               )
  :components ((:module "src"
                :components
                ((:file "arrows" :depends-on ("parse" "pass" "backend" "be"))
                 (:file "att" :depends-on ("util"))
                 (:file "backend" :depends-on ("util" "att"))
                 (:module "be"
                          :pathname "backend"
                          :depends-on ("backend")
                  :components ((:file "stream")
                               (:file "sequence" :depends-on ("stream"))
                               (:file "fast-io" :depends-on ("sequence"))))
                 (:file "token")
                 (:file "pass" :depends-on ("util" "att"))
                 (:file "parse" :depends-on ("att" "lexer" "le" "parser"))
                 (:file "lexer")
                 (:module "le"
                          :pathname "lexer"
                          :depends-on ("lexer" "token")
                          :components ((:file "default")))
                 (:file "parser" :depends-on ("token" "att" "lexer" "le"))
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
  :in-order-to ((test-op (test-op arrows-test))))
