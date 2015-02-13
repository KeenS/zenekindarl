#|
  This file is a part of clta project.
  Copyright (c) 2014 κeen
|#

(in-package :cl-user)
(defpackage clta.backend-test
  (:use :cl
        :clta.util
        :clta.att
        :clta.backend
        :clta.backend.stream
   :cl-test-more)
  (:import-from :html-encode
                :encode-for-tt))
(in-package :clta.backend-test)

(defmacro ast-is (got expect doc)
  `(is ,got ,expect ,doc :test #'equalp))

(plan nil)
(diag "backend tests")

(defvar *stream-output-backend* (make-instance 'stream-backend
                                               :stream *standard-output*))

(ast-is
 (emit-code *stream-output-backend* (att-output (att-string "aaa")))
 
 `(write-sequence "aaa" ,*standard-output*)
 "stream backend of att-string with att-output")

(ast-is
 (emit-code *stream-output-backend* (att-eval '(+ 1 2)))

 '(+ 1 2)
 "stream backend of att-eval")

(ast-is
 (emit-code *stream-output-backend* (att-output (att-eval '(+ 1 2))))
 `(write-sequence (encode-for-tt (princ-to-string(+ 1 2))) ,*standard-output*)
 "stream backend of att-eval with att-output")

(ast-is
 (emit-code *stream-output-backend* (att-output (att-variable 'foo)))

 `(write-sequence (encode-for-tt (princ-to-string foo)) ,*standard-output*)
 "stream backend of att-variable with att-output")

(ast-is
 (emit-code *stream-output-backend* (att-output (att-variable 'foo :string)))
 `(write-sequence (encode-for-tt foo) ,*standard-output*)
 "stream backend of att-variable with type with att-output")

(ast-is
 (emit-code *stream-output-backend*
  (att-if
   (att-eval t)
   (att-string "foo")))

 '(if t
   "foo"
   nil)
 "stream backend of att-if with else omitted")

(ast-is
 (emit-code *stream-output-backend*
  (att-if
   (att-eval t)
   (att-string "foo")
   (att-string "bar")))

 '(if t
   "foo"
   "bar")
 "stream backend of att-if")

(is-expand
 '#.(emit-code *stream-output-backend*
            (att-loop
             (att-eval ''((:foo 1) (:foo 2) (:foo 3)))
             (att-variable 'foo)))

 '(loop :for $loopvar :in '((:foo 1) (:foo 2) (:foo 3))
   :do foo )
 "stream backend of loop")

(finalize)
