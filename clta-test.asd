#|
  This file is a part of clta project.
  Copyright (c) 2014 κeen
|#

(in-package :cl-user)
(defpackage clta-test-asd
  (:use :cl :asdf))
(in-package :clta-test-asd)

(defsystem clta-test
  :author "κeen"
  :license ""
  :depends-on (:clta
               :cl-test-more)
  :components ((:module "t"
                :components
                ((:test-file "clta")
                 (:test-file "att")
                 (:test-file "pass")
                 (:test-file "backend")
                 (:test-file "parse"))))

  :defsystem-depends-on (:cl-test-more)
  :perform (test-op :after (op c)
                    (funcall (intern #. (string :run-test-system) :cl-test-more)
                             c)
                    (asdf:clear-system c)))
