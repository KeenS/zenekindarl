#|
  This file is a part of zenekindarl project.
  Copyright (c) 2014 κeen
|#


#-asdf3.1 (error "zenekindarl-test requires ASDF 3.1")
(defsystem zenekindarl-test
  :author "κeen"
  :license ""
  :depends-on (:zenekindarl
               :prove
               :flexi-streams)
  :defsystem-depends-on (:prove)
  :components ((:module "t"
                :components
                ((:test-file "zenekindarl")
                 (:test-file "att")
                 (:test-file "pass")
                 (:test-file "backend")
                 (:test-file "parse"))))

  :perform (test-op (op c) (uiop:symbol-call :prove :run-test-system c)))
