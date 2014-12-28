#|
This file is a part of clta project.
Copyright (c) 2014 κeen
|#

(in-package :cl-user)
(defpackage clta.pass-test
  (:use :cl
        :clta.att
        :clta.pass
        :clta.util
        :cl-test-more))
(in-package :clta.pass-test)

(plan nil)
(diag "test pass")

(is
 (flatten-pass
  (att-progn
   (att-string "start")
   (att-progn (att-variable 'foo))
   (att-string "end"))
  ())

 (att-progn
  (att-string "start")
  (att-variable 'foo)
  (att-string "end"))
 "flatten-pass for progn"
 :test #'att-equal)

(is
 (flatten-pass
  (att-progn
   (att-string "start")
   (att-progn (att-progn (att-variable 'foo)))
   (att-string "end"))
  ())

 (att-progn
  (att-string "start")
  (att-variable 'foo)
  (att-string "end"))
 "flatten-pass for nested progn"
 :test #'att-equal)

(is
 (flatten-pass
  (att-progn
   (att-string "start")
   (att-if
    (att-eval t)
    (att-progn
     (att-string "foo is: ")
     (att-progn (att-variable 'foo))))
   (att-string "end"))
  ())

 (att-progn
  (att-string "start")
  (att-if
   (att-progn (att-eval t))
   (att-progn
    (att-string "foo is: ")
    (att-variable 'foo))
   (att-progn (att-nil)))
  (att-string "end"))
 "flatten-pass for if"
 :test #'att-equal)

(is
 (flatten-pass
  (att-progn
   (att-string "start")
   (att-loop
    (att-eval t)
    (att-progn
     (att-string "foo is: ")
     (att-progn (att-variable 'foo)))
    (att-progn (att-variable 'foo)))
   (att-string "end"))
  ())

 (att-progn
  (att-string "start")
  (att-loop
   (att-progn (att-eval t))
   (att-progn
    (att-string "foo is: ")
    (att-variable 'foo))
   (att-progn (att-variable 'foo)))
  (att-string "end"))
 "flatten-pass for loop"
 :test #'att-equal)

(is
 (remove-progn-pass
  (att-progn (att-string "test"))
  ())
 (att-string "test")
 "remove-progn-pass for simple progn"
 :test #'att-equal)

(is
 (remove-progn-pass
  (att-if
   (att-progn (att-eval t))
   (att-progn
    (att-string "foo is: ")
    (att-variable 'foo))
   (att-progn (att-nil)))
  ())
 (att-if
  (att-eval t)
  (att-progn
   (att-string "foo is: ")
   (att-variable 'foo)))
 "remove-progn-pass for if"
 :test #'att-equal)


(is
 (append-sequence-pass
  (att-progn
   (att-string "foo")
   (att-string "bar"))
  ())
 (att-progn (att-string "foobar"))
 "append-sequence-pass for string"
 :test #'att-equal)

(finalize)
