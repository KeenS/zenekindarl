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
   :make-backend)
  (:import-from :clta.backend.stream
   :make-backend)
  (:import-from :clta.backend.sequence
   :make-backend)
  (:import-from :babel
   :string-to-octets)
  (:import-from :fast-io
                :fast-output-stream))
(in-package :clta-test)

;; NOTE: To run this test file, execute `(asdf:test-system :clta)' in your Lisp.

(defparameter *suites*
  '(("foo" () "foo" "simple string")
    ("<foo>" () "<foo>" "simple string containing html meta chars")
    ("bar {{var bar}}" (:bar "bar") "bar bar" "simple variable")
    ("bar {{var bar}}" (:bar "<bar>") "bar &lt;bar&gt;" "variable containing html meta char")
    ("bar{{repeat 3}} {{var bar}}{{endrepeat}}" (:bar "bar") "bar bar bar bar" "repeat")
    ("{{loop items as i}}<li>{{var i}}</li>{{endloop}}" (:items ("uragasumi" "hakkaisan" "dassai")) "<li>uragasumi</li><li>hakkaisan</li><li>dassai</li>" "loop")
    ("{{loop items as i}}<li>{{var i}}</li>{{endloop}}" (:items ()) "" "loop with loopee being nil")
    ("<li>{{if new-p}}New! {{endif}}blahblah</li>" (:new-p t) "<li>New! blahblah</li>" "if")
    ("<li>{{if new-p}}New! {{endif}}blahblah</li>" (:new-p nil) "<li>blahblah</li>" "if with condition being nil")
    ("<li>{{if new-p}}New! {{else}}Old! {{endif}}blahblah</li>" (:new-p t)"<li>New! blahblah</li>" "if with else")
    ("<li>{{if new-p}}New! {{else}}Old! {{endif}}blahblah</li>" (:new-p nil) "<li>Old! blahblah</li>" "if with else and condition being nil")
    ("the content of foo is {{insert foo}}" () "the content of foo is {{repeat 2 as i}}bar{{endrepeat}}" "insert")
    ("the content of var is {{insert var}}" () "the content of var is {{var bar}}" "insert with insertee cotaining template string")
    ("the content of foo is {{include foo}}" () "the content of foo is barbar" "against include")
    ("the content of var is {{include var}}" (:bar "var") "the content of var is var" "include with includee cotaining template string")))

(plan nil)
(diag "compile test with stream backend")
(loop :for (template args result description) :in *suites*
      :do (ok (compile-template-string (make-backend :stream) template ()) description))

(diag "compile test with octet stream backend")
(loop :for (template args result description) :in *suites*
      :do (ok (compile-template-string (make-backend :octet-stream) template ()) description))

(diag "compile test with string backend")
(loop :for (template args result description) :in *suites*
      :do (ok (compile-template-string (make-backend :string) template ()) description))

(diag "compile test with octet backend")
(loop :for (template args result description) :in *suites*
      :do (ok (compile-template-string (make-backend :octet) template ()) description))

(diag "render test with stream backend")
(loop :for (template args result description) :in *suites*
      :do (is-print (apply #'render template args) result description))

(diag "render test with octet stream backend")
#+nil
(loop :for (template args result description) :in *suites*
      :do (is-print (apply #'render template `(,(make-instance 'fast-output-stream) :backend ,(make-backend :octet-stream) ,@args)) (string-to-octets result) description))

(diag "render test with string backend")
(loop :for (template args result description) :in *suites*
      :do (is (apply #'render template (cons :backend (cons (make-backend :string) args))) result description))

(diag "render test with octet backend")
(loop :for (template args result description) :in *suites*
      :do (is (apply #'render template (cons :backend (cons (make-backend :octet) args))) (string-to-octets result) :test #'equalp description))

(finalize)
