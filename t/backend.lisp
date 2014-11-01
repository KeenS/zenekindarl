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
        :cl-test-more))
(in-package :clta.backend-test)

(defmacro ast-is (got expect)
  `(is ,got ,expect :test #'equalp))

(plan nil)

(ast-is
 (generate-write-code (att-string "aaa") 's)
 
 '(write-sequence "aaa" s))

(ast-is
 (generate-write-code
  (att-octets (octets 1 2 3)) 's)
 
 `(write-sequence ,(octets 1 2 3) s))

(ast-is
 (generate-write-code
  (att-eval '(+ 1 2)) 's)

 '(+ 1 2))

(ast-is
 (generate-write-code
  (att-eval-to-output '(+ 1 2)) 's)

 '(princ (+ 1 2) s))

(ast-is
 (generate-write-code
  (att-variable 'foo) 's)

 '(princ foo s))

(ast-is
 (generate-write-code
  (att-variable 'foo :string) 's)

 '(write-sequence foo s))

(ast-is
 (generate-write-code
  (att-variable 'foo :octets) 's)

 '(write-sequence foo s))

(ast-is
 (generate-write-code
  (att-if
   (att-eval t)
   (att-string "foo")) 's)

 '(if t
   (write-sequence "foo" s)
   nil))

(ast-is
 (generate-write-code
  (att-if
   (att-eval t)
   (att-string "foo")
   (att-string "bar")) 's)

 '(if t
   (write-sequence "foo" s)
   (write-sequence "bar" s)))

(ast-is
 (generate-write-code
  (att-loop
   (att-eval ''((:foo 1) (:foo 2) (:foo 3)))
   (att-variable 'foo))
  's)

 '(loop for (gensym) in '((:foo 1) (:foo 2) (:foo 3))
      (princ foo s)))
(finalize)
