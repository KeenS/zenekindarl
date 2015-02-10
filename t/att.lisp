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
(diag "att tests")
(is (type-of (att-string "string"))
    'att-string
    "att-string constructor")
(is (att-string "string") (att-string "string")
    "att-string equality"
    :test #'att-equal)

(is (type-of (att-variable 'var))
    'att-variable
    "att-variable constructor")
(is (att-variable 'var)
    (att-variable 'var)
    "att-variable equality"
    :test #'att-equal)

(is (type-of (att-variable 'var :string))
    'att-variable
    "att-string constructor")
(is (att-variable 'var :string)
    (att-variable 'var :string)
    "att-string equality"
    :test #'att-equal)
(isnt (att-variable 'var :string)
      (att-variable 'var :anything)
      "att-string equality with different type"
      :test #'att-equal)
(is (att-variable 'var)
    (att-variable 'var :anything)
    "att-string equality with type omitted"
    :test #'att-equal)


(is (type-of (att-gensym "var"))
    'att-gensym
    "att-gensym constructor")
(is (att-gensym "var")
    (att-gensym "var")
    "att-gensym equality"
    :test #'att-equal)

(is (type-of (att-gensym "var" :string))
    'att-gensym
    "att-string constructor")
(is (att-gensym "var" :string)
    (att-gensym "var" :string)
    "att-string equality"
    :test #'att-equal)
(isnt (att-gensym "var" :string)
      (att-gensym "var" :anything)
      "att-string equality with different type"
      :test #'att-equal)
(is (att-gensym "var")
    (att-gensym "var" :anything)
    "att-string equality with type omitted"
    :test #'att-equal)

(is (type-of (att-eval '(+ 1 2)))
    'att-eval
    "att-eval constructor")
(is (att-eval '(+ 1 2))
    (att-eval '(+ 1 2))
    "att-eval equality"
    :test #'att-equal)

(is (type-of (att-output (att-string "hello")))
    'att-output
    "att-output constructor")
(is (att-output (att-string "hello"))
    (att-output (att-string "hello"))
    "att-output equality"
    :test #'att-equal)

(is (type-of (att-progn (att-string "string")
                        (att-string "string2")))
    'att-progn
    "att-progn constructor")
(is (att-progn (att-string "string")
               (att-string "string2"))
    (att-progn (att-string "string")
               (att-string "string2"))
    "att-progn equality"
    :test #'att-equal)

(is (type-of (att-if
              (att-variable 'var)
              (att-string "then")))
    'att-if
    "att-if constructor with else omitted")
(is (att-if
     (att-variable 'var)
     (att-string "then"))
    (att-if
     (att-variable 'var)
     (att-string "then"))
    "att-if equality with else omitted"
    :test #'att-equal)
(is (type-of (att-if
              (att-variable 'var)
              (att-string "then")
              (att-string "else")))
    'att-if
    "att-if equality")
(is (att-if
     (att-variable 'var)
     (att-string "then")
     (att-string "else"))
    (att-if
     (att-variable 'var)
     (att-string "then")
     (att-string "else"))
    "att-if equality"
    :test #'att-equal)

(is (type-of (att-loop
              (att-constant '(list (:foo 1) (:foo 2) (:foo 3)))
              (att-variable 'foo)))
    'att-loop
    "att-loop constructor with loop variable omitted")
(is (att-loop
     (att-constant '(list (:foo 1) (:foo 2) (:foo 3)))
     (att-variable 'foo))
    (att-loop
     (att-constant '(list (:foo 1) (:foo 2) (:foo 3)))
     (att-variable 'foo))
    "att-loop equality with loop variable omitted"
    :test #'att-equal)

(is (type-of (att-loop
              (att-constant '(list 1 2 3))
              (att-variable 'foo)
              (att-variable 'foo)))
    'att-loop
    "att-loop constructor")
(is (att-loop
     (att-constant '(list 1 2 3))
     (att-variable 'foo)
     (att-variable 'foo))
    (att-loop
     (att-constant '(list 1 2 3))
     (att-variable 'foo)
     (att-variable 'foo))
    "att-loop equality"
    :test #'att-equal)

(is (type-of (att-include "template.tmpl"))
    'att-include
    "att-include constructor")
(is (att-include "template.tmpl")
    (att-include "template.tmpl")
    "att-include equality"
    :test #'att-equal)

;; blah blah blah.

(finalize)
