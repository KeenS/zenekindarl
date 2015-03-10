#|
  This file is a part of arrows project.
  Copyright (c) 2014 κeen
|#

(in-package :cl-user)
(defpackage arrows-test-asd
  (:use :cl :asdf))
(in-package :arrows-test-asd)

(defsystem arrows-test
  :author "κeen"
  :license ""
  :depends-on (:arrows
               :prove
               :flexi-streams)
  :components ((:module "t"
                :components
                ((:test-file "arrows")
                 (:test-file "att")
                 (:test-file "pass")
                 (:test-file "backend")
                 (:test-file "parse"))))

  :defsystem-depends-on (:cl-test-more)
  :perform (test-op :after (op c)
                    (funcall (intern #. (string :run-test-system) :cl-test-more)
                             c)
                    (asdf:clear-system c)))
