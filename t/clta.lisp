#|
  This file is a part of clta project.
  Copyright (c) 2014 κeen
|#

(in-package :cl-user)
(defpackage clta-test
  (:use :cl
   :clta
        :cl-test-more)
  (:import-from :clta.backend
                :make-backend))
(in-package :clta-test)

;; NOTE: To run this test file, execute `(asdf:test-system :clta)' in your Lisp.


(plan nil)
(is-print (render "bar {{var bar}}" :bar "bar") "bar bar")
(is-print (render "bar{{repeat 3}} {{var bar}}{{endrepeat}}" :bar "bar") "bar bar bar bar")
(is-print (render "{{loop items as i}}<li>{{var i}}</li>{{endloop}}" :items '("uragasumi" "hakkaisan" "dassai")) "<li>uragasumi</li><li>hakkaisan</li><li>dassai</li>")
(is-print (render "<li>{{if new-p}}New! {{endif}}blahblah</li>" :new-p t) "<li>New! blahblah</li>")
(is-print (render "<li>{{if new-p}}New! {{endif}}blahblah</li>" :new-p nil) "<li>blahblah</li>")
(is-print (render "<li>{{if new-p}}New! {{else}}Old! {{endif}}blahblah</li>" :new-p t) "<li>New! blahblah</li>")
(is-print (render "<li>{{if new-p}}New! {{else}}Old! {{endif}}blahblah</li>" :new-p nil) "<li>Old! blahblah</li>")
(is-print (render "the content of foo is {{insert foo}}")
          "the content of foo is {{repeat 2 as i}}bar{{endrepeat}}")
(is-print (render "the content of foo is {{include foo}}") "the content of foo is barbar")
(is-print (render "the content of var is {{insert var}}")
          "the content of var is {{var bar}}")
(is-print (render "the content of var is {{include var}}" :bar "var") "the content of var is var")

;; blah blah blah.

(finalize)
