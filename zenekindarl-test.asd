#|
  This file is a part of zenekindarl project.
  Copyright (c) 2014 κeen
|#

(in-package :cl-user)
(defpackage zenekindarl-test-asd
  (:use :cl :asdf))
(in-package :zenekindarl-test-asd)

(defsystem zenekindarl-test
  :author "κeen"
  :license ""
  :depends-on (:zenekindarl
               :prove
               :flexi-streams)
  :components ((:module "t"
                :components
                ((:test-file "zenekindarl")
                 (:test-file "att")
                 (:test-file "pass")
                 (:test-file "backend")
                 (:test-file "parse"))))

  :defsystem-depends-on (:prove)
  :perform (test-op :after (op c)
                    (funcall (intern #. (string :run-test-system) :prove)
                             c)
                    (asdf:clear-system c)))
