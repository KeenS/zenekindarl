#|
This file is a part of clta project.
Copyright (c) 2014 κeen
|#

(in-package :cl-user)
(defpackage clta.att-test
  (:use :cl
        :clta.att
        :clta.util
        :cl-test-more))
(in-package :clta.att-test)

;; NOTE: To run this test file, execute `(asdf:test-system :clta)' in your Lisp.

(plan nil)
(is (type-of (att-string "string"))
    'att-string)
(is (att-string "string") (att-string "string")
    :test #'att-equal)

(is (type-of (att-variable 'var))
    'att-variable)
(is (att-variable 'var)
    (att-variable 'var)
    :test #'att-equal)

(is (type-of (att-variable 'var :string))
    'att-variable)
(is (att-variable 'var :string)
    (att-variable 'var :string)
    :test #'att-equal)
(isnt (att-variable 'var :string)
        (att-variable 'var :anything)
        :test #'att-equal)
(is (att-variable 'var)
    (att-variable 'var :anything)
    :test #'att-equal)

(is (type-of (att-eval '(+ 1 2)))
    'att-eval)
(is (att-eval '(+ 1 2))
    (att-eval '(+ 1 2))
    :test #'att-equal)

(is (type-of (att-output (att-string "hello")))
    'att-output)
(is (att-output (att-string "hello"))
    (att-output (att-string "hello"))
    :test #'att-equal)

(is (type-of (att-progn (att-string "string")
                        (att-string "string2")))
    'att-progn)
(is (att-progn (att-string "string")
               (att-string "string2"))
    (att-progn (att-string "string")
               (att-string "string2"))
    :test #'att-equal)

(is (type-of (att-if
              (att-variable 'var)
              (att-string "then")))
    'att-if)
(is (att-if
     (att-variable 'var)
     (att-string "then"))
    (att-if
     (att-variable 'var)
     (att-string "then"))
    :test #'att-equal)
(is (type-of (att-if
              (att-variable 'var)
              (att-string "then")
              (att-string "else")))
    'att-if)
(is (att-if
     (att-variable 'var)
     (att-string "then")
     (att-string "else"))
    (att-if
     (att-variable 'var)
     (att-string "then")
     (att-string "else"))
    :test #'att-equal)

(is (type-of (att-loop
              (att-constant '(list (:foo 1) (:foo 2) (:foo 3)))
              (att-variable 'foo)))
    'att-loop)
(is (att-loop
     (att-constant '(list (:foo 1) (:foo 2) (:foo 3)))
     (att-variable 'foo))
    (att-loop
     (att-constant '(list (:foo 1) (:foo 2) (:foo 3)))
     (att-variable 'foo))
    :test #'att-equal)

(is (type-of (att-loop
              (att-constant '(list 1 2 3))
              (att-variable 'foo)
              (att-variable 'foo)))
    'att-loop)
(is (att-loop
     (att-constant '(list 1 2 3))
     (att-variable 'foo)
     (att-variable 'foo))
    (att-loop
     (att-constant '(list 1 2 3))
     (att-variable 'foo)
     (att-variable 'foo))
    :test #'att-equal)

(is (type-of (att-include "template.tmpl"))
    'att-include)
(is (att-include "template.tmpl")
    (att-include "template.tmpl")
    :test #'att-equal)

;; blah blah blah.

(finalize)
