#|
This file is a part of clta project.
Copyright (c) 2014 κeen
|#

(in-package :cl-user)
(defpackage clta.parse-test
  (:use :cl
        :clta.parse
        :clta.util
        :cl-test-more))
(in-package :clta.parse-test)

(plan nil)
(is (multiple-value-list (analyze-location "abc" 0 0))
    '(0 3))
(is (multiple-value-list (analyze-location "abc
d" 0 0))
    '(1 1))
(is (multiple-value-list (analyze-location "abc" 1 2))
    '(1 5))
(is (multiple-value-list (analyze-location "abc

d" 1 2))
    '(2 4))

(finalize)

