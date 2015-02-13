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
(is-print (render "foo") "foo"
          "render test against simple string")
(is-print (render "<foo>") "<foo>"
          "render test against simple string containing html meta chars")
(is-print (render "bar {{var bar}}" :bar "bar") "bar bar"
          "render test against simple variable")
(is-print (render "bar {{var bar}}" :bar "<bar>") "bar &lt;bar&gt;"
          "render test against variable containing html meta char")
(is-print (render "bar{{repeat 3}} {{var bar}}{{endrepeat}}" :bar "bar") "bar bar bar bar"
          "render test against repeat")
(is-print (render "{{loop items as i}}<li>{{var i}}</li>{{endloop}}" :items '("uragasumi" "hakkaisan" "dassai")) "<li>uragasumi</li><li>hakkaisan</li><li>dassai</li>"
          "render test against loop")
(is-print (render "{{loop items as i}}<li>{{var i}}</li>{{endloop}}" :items '()) ""
          "render test against loop with loopee being nil")
(is-print (render "<li>{{if new-p}}New! {{endif}}blahblah</li>" :new-p t) "<li>New! blahblah</li>"
          "render test against if")
(is-print (render "<li>{{if new-p}}New! {{endif}}blahblah</li>" :new-p nil) "<li>blahblah</li>"
          "render test against if with condition being nil")
(is-print (render "<li>{{if new-p}}New! {{else}}Old! {{endif}}blahblah</li>" :new-p t) "<li>New! blahblah</li>"
          "render test against if with else")
(is-print (render "<li>{{if new-p}}New! {{else}}Old! {{endif}}blahblah</li>" :new-p nil) "<li>Old! blahblah</li>"
          "render test against if with else and condition being nil")
(is-print (render "the content of foo is {{insert foo}}")
          "the content of foo is {{repeat 2 as i}}bar{{endrepeat}}"
          "render test against insert")
(is-print (render "the content of var is {{insert var}}")
          "the content of var is {{var bar}}"
          "render test against insert with insertee cotaining template string")
(is-print (render "the content of foo is {{include foo}}") "the content of foo is barbar"
          "render test against include")
(is-print (render "the content of var is {{include var}}" :bar "var") "the content of var is var"
          "render test against include with includee cotaining template string")

;; blah blah blah.

(finalize)
