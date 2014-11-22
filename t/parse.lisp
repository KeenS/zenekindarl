#|
This file is a part of clta project.
Copyright (c) 2014 κeen
|#

(in-package :cl-user)
(defpackage clta.parse-test
  (:use :cl
        :clta.att
        :clta.parse
        :clta.util
        :cl-test-more))
(in-package :clta.parse-test)

(plan nil)

(is (parse-template-string "aaa")
    (att-progn (att-output (att-string "aaa")))
    :test #'att-equal)

(is (parse-template-string "{{var sym}}")
    (att-progn (att-output (att-variable 'sym)))
    :test #'att-equal)

(is (parse-template-string "{{if cond}}aaa{{endif}}")
    (att-progn (att-if (att-variable 'cond)
                       (att-progn (att-output (att-string "aaa")))
                       (att-nil)))
    :test #'att-equal)

(is (parse-template-string "{{if cond}}aaa{{else}}bbb{{endif}}")
    (att-progn (att-if (att-variable 'cond)
                       (att-progn (att-output (att-string "aaa")))
                       (att-progn (att-output (att-string "bbb")))))
    :test #'att-equal)

(is (parse-template-string "{{repeat 10}}<li>item</li>{{endrepeat}}")
    (att-progn (att-loop (att-constant '(1 2 3 4 5 6 7 8 9 10))
                         (att-progn (att-output (att-string "<li>item</li>")))
                         (att-variable (gensym "repeatvar")))))

(is (parse-template-string "{{repeat 10 as i}}<li>item{{var i}}</li>{{endrepeat}}")
    (att-progn (att-loop (att-constant '(1 2 3 4 5 6 7 8 9 10))
                         (att-progn (att-output (att-string "<li>item"))
                                    (att-output (att-variable 'i))
                                    (att-output (att-string "</li>")))
                         (att-variable 'i))))

(is (parse-template-string "{{loop seq as i}}<li>item{{var i}}</li>{{endloop}}")
    (att-progn (att-loop (att-variable 'seq)
                         (att-progn (att-output (att-string "<li>item"))
                                    (att-output (att-variable 'i))
                                    (att-output (att-string "</li>")))
                         (att-variable 'i))))

(finalize)

