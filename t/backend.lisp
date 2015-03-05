#|
This file is a part of arrows project.
Copyright (c) 2014 κeen
|#

(in-package :cl-user)
(defpackage arrows.backend-test
  (:use :cl
        :arrows.util
        :arrows.att
        :arrows.backend
        :arrows.backend.stream
        :cl-test-more)
  (:import-from :html-encode
                :encode-for-tt))
(in-package :arrows.backend-test)

(plan nil)
(diag "backend tests")

(is-expand
 '#.(emit-code (make-backend :stream) (att-output (att-string "aaa")))
 
 '(write-string "aaa" $stream)
 "stream backend of att-string with att-output")

(is-expand
 '#.(emit-code (make-backend :stream) (att-eval '(+ 1 2)))

 '(+ 1 2)
 "stream backend of att-eval")

(is-expand
 '#.(emit-code (make-backend :stream) (att-output (att-eval '(+ 1 2))))
 '(write-string (encode-for-tt (princ-to-string(+ 1 2))) $stream)
 "stream backend of att-eval with att-output")

(is-expand
 '#.(emit-code (make-backend :stream) (att-output (att-variable 'foo)))

 '(write-string (encode-for-tt (princ-to-string foo)) $stream)
 "stream backend of att-variable with att-output")

(is-expand
 '#.(emit-code (make-backend :stream) (att-output (att-variable 'foo :string)))
 '(write-string (encode-for-tt foo) $stream)
 "stream backend of att-variable with type with att-output")

(is-expand
 '#.(emit-code (make-backend :stream)
               (att-if
                (att-eval t)
                (att-string "foo")))

 '(if t
   "foo"
   nil)
 "stream backend of att-if with else omitted")

(is-expand
 '#.(emit-code (make-backend :stream)
               (att-if
                (att-eval t)
                (att-string "foo")
                (att-string "bar")))

 '(if t
   "foo"
   "bar")
 "stream backend of att-if")

(is-expand
 '#.(emit-code (make-backend :stream)
               (att-loop
                (att-eval ''((:foo 1) (:foo 2) (:foo 3)))
                (att-variable 'foo)))

 '(loop :for $loopvar :in '((:foo 1) (:foo 2) (:foo 3))
     :do foo )
 "stream backend of loop")

(finalize)
