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
(is (att-equal (att-string "string") (att-string "string"))
    t)

(is (type-of (att-octets (octets 1 2 3)))
    'att-octets)
(is (att-equal (att-octets (octets 1 2 3))
               (att-octets (octets 1 2 3)))
    t)

(is (type-of (att-variable 'var))
    'att-variable)
(is (att-equal (att-variable 'var)
               (att-variable 'var))
    t)

(is (type-of (att-variable 'var :string))
    'att-variable)
(is (att-equal (att-variable 'var :string)
               (att-variable 'var :string))
    t)
(is (att-equal (att-variable 'var :string)
               (att-variable 'var :anything))
    nil)
(is (att-equal (att-variable 'var)
               (att-variable 'var :anything))
    t)

(is (type-of (att-eval '(+ 1 2)))
    'att-eval)
(is (att-equal (att-eval '(+ 1 2))
               (att-eval '(+ 1 2)))
    t)

(is (type-of (att-progn (att-string "string")
                        (att-string "string2")))
    'att-progn)
(is (att-equal (att-progn (att-string "string")
                          (att-string "string2"))
               (att-progn (att-string "string")
                          (att-string "string2")))
    t)

(is (type-of (att-if
              (att-variable 'var)
              (att-string "then")))
    'att-if)
(is (att-equal (att-if
                (att-variable 'var)
                (att-string "then"))
               (att-if
                (att-variable 'var)
                (att-string "then")))
    t)
(is (type-of (att-if
              (att-variable 'var)
              (att-string "then")
              (att-string "else")))
    'att-if)
(is (att-equal (att-if
                (att-variable 'var)
                (att-string "then")
                (att-string "else"))
               (att-if
                (att-variable 'var)
                (att-string "then")
                (att-string "else")))
    t)

(is (type-of (att-loop
              (att-eval '(list (:foo 1) (:foo 2) (:foo 3)))
              (att-variable 'foo)))
    'att-loop)
(is (att-equal (att-loop
                (att-eval '(list (:foo 1) (:foo 2) (:foo 3)))
                (att-variable 'foo))
               (att-loop
                (att-eval '(list (:foo 1) (:foo 2) (:foo 3)))
                (att-variable 'foo)))
    t)

(is (type-of (att-loop
              (att-eval '(list 1 2 3))
              (att-variable 'foo)
              (att-variable 'foo)))
    'att-loop)
(is (att-equal (att-loop
                (att-eval '(list 1 2 3))
                (att-variable 'foo)
                (att-variable 'foo))
               (att-loop
                (att-eval '(list 1 2 3))
                (att-variable 'foo)
                (att-variable 'foo)))
    t)

(is (type-of (att-include "template.tmpl"))
    'att-include)
(is (att-equal (att-include "template.tmpl")
               (att-include "template.tmpl"))
    t)

;; blah blah blah.

(finalize)
