#|
This file is a part of arrows project.
Copyright (c) 2014 κeen
|#

(in-package :cl-user)
(defpackage arrows.parse-test
  (:use :cl
        :arrows.att
        :arrows.parse
        :arrows.util
        :cl-test-more))
(in-package :arrows.parse-test)

(plan nil)
(diag "test parse")

(is (parse-template-string "aaa")
    (att-progn (att-output (att-string "aaa")))
    "simple text"
    :test #'att-equal)

(is (parse-template-string "{{var sym}}")
    (att-progn
     (att-output (att-string ""))
     (att-output (att-variable 'arrows.lexer.default::sym))
     (att-output (att-string "")))
    "var"
    :test #'att-equal)

(is (parse-template-string "{{if cond}}aaa{{endif}}")
    (att-progn
     (att-output (att-string ""))
     (att-if (att-variable 'arrows.lexer.default::cond)
             (att-progn (att-output (att-string "aaa")))
             (att-nil))
     (att-output (att-string "")))
    "if"
    :test #'att-equal)

(is (parse-template-string "{{if cond}}aaa{{else}}bbb{{endif}}")
    (att-progn
     (att-output (att-string ""))
     (att-if (att-variable 'arrows.lexer.default::cond)
             (att-progn (att-output (att-string "aaa")))
             (att-progn (att-output (att-string "bbb"))))
     (att-output (att-string "")))
    "if else"
    :test #'att-equal)

(is (parse-template-string "{{repeat 10}}<li>item</li>{{endrepeat}}")
    (att-progn
     (att-output (att-string ""))
     (att-loop (att-constant '(1 2 3 4 5 6 7 8 9 10))
               (att-progn (att-output (att-string "<li>item</li>")))
               (att-gensym "loopvar"))
     (att-output (att-string "")))
    "repeat"
    :test #'att-equal)

(is (parse-template-string "{{repeat 10 as i}}<li>item{{var i}}</li>{{endrepeat}}")
    (att-progn
     (att-output (att-string ""))
     (att-loop (att-constant '(1 2 3 4 5 6 7 8 9 10))
                         (att-progn (att-output (att-string "<li>item"))
                                    (att-output (att-variable 'arrows.lexer.default::i))
                                    (att-output (att-string "</li>")))
                         (att-variable 'arrows.lexer.default::i))
     (att-output (att-string "")))
    "repeat with index"
    :test #'att-equal)

(is (parse-template-string "{{loop seq as i}}<li>item{{var i}}</li>{{endloop}}")
    (att-progn
     (att-output (att-string ""))
     (att-loop (att-variable 'arrows.lexer.default::seq)
                         (att-progn (att-output (att-string "<li>item"))
                                    (att-output (att-variable 'arrows.lexer.default::i))
                                    (att-output (att-string "</li>")))
                         (att-variable 'arrows.lexer.default::i))
     (att-output (att-string "")))
    "loop"
    :test #'att-equal)

(is (parse-template-string "the content of foo is {{insert \"foo\"}}")
    (att-progn
     (att-output (att-string "the content of foo is "))
     (att-output (att-string "{{repeat 2 as i}}bar{{endrepeat}}"))
     (att-output (att-string "")))
    "insert"
    :test #'att-equal)

(is (parse-template-string "the content of foo is {{include \"foo\"}}")
    (att-progn
     (att-output
      (att-string "the content of foo is "))
     (att-progn
      (att-output (att-string ""))
      (att-loop
       (att-constant '(1 2))
       (att-progn (att-output (att-string "bar")))
       (att-variable 'arrows.lexer.default::i))
      (att-output (att-string "")))
     (att-output (att-string "")))
    "include"
    :test #'att-equal)
(finalize)

