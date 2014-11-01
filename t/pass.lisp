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

(defmacro att-is (got expect)
  `(is ,got ,expect :test #'att-equal))

(plan nil)
(att-is
 (att-progn
  (att-string "start")
  (att-variable 'foo)
  (att-string "end"))

 (flatten-pass
  (att-progn
   (att-string "start")
   (att-progn (att-variable 'foo))
   (att-string "end"))))

(att-is
 (att-progn
  (att-string "start")
  (att-variable 'foo)
  (att-string "end"))

 (flatten-pass
  (att-progn
   (att-string "start")
   (att-progn (att-progn (att-variable 'foo)))
   (att-string "end"))))

(att-is
 (att-progn
  (att-string "start")
  (att-if
   (att-progn (att-eval t))
   (att-progn
    (att-string "foo is: ")
    (att-variable 'foo))
   (att-progn (att-nil)))
  (att-string "end"))

 (flatten-pass
  (att-progn
   (att-string "start")
   (att-if
    (att-eval t)
    (att-progn
     (att-string "foo is: ")
     (att-progn (att-variable 'foo))))
   (att-string "end"))))

(att-is
 (att-progn
  (att-string "start")
  (att-loop
   (att-progn (att-eval t))
   (att-progn
    (att-string "foo is: ")
    (att-variable 'foo))
   (att-progn (att-variable 'foo)))
  (att-string "end"))

 (flatten-pass
  (att-progn
   (att-string "start")
   (att-loop
    (att-eval t)
    (att-progn
     (att-string "foo is: ")
     (att-progn (att-variable 'foo)))
    (att-progn (att-variable 'foo)))
   (att-string "end"))))

(att-is
 (att-string "test")
 (remove-progn-pass
  (att-progn (att-string "test"))))

(att-is
 (att-if
  (att-eval t)
  (att-progn
   (att-string "foo is: ")
   (att-variable 'foo)))
 (remove-progn-pass
  (att-if
   (att-progn (att-eval t))
   (att-progn
    (att-string "foo is: ")
    (att-variable 'foo))
   (att-progn (att-nil)))))

(att-is
 (att-loop
  (att-eval t)
  (att-progn
   (att-string "foo is: ")
   (att-variable 'foo))
  (att-variable 'foo))
 (att-loop
  (att-eval t)
  (att-progn
   (att-string "foo is: ")
   (att-variable 'foo))
  (att-variable 'foo)))

(att-is
 (att-progn (att-string "foobar"))
 (append-sequence-pass
  (att-progn
   (att-string "foo")
   (att-string "bar"))))
(finalize)
