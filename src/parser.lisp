(in-package :cl-user)
(defpackage :arrows.parser
  (:use :cl :arrows.util :arrows.token :arrows.att :mpc)
  (:export :=template))
(in-package :arrows.parser)

(defun =token-string () (=satisfies #'token-string-p))
(defun =token-variable () (=satisfies #'token-variable-p))
(defun =token-if () (=satisfies #'token-if-p))
(defun =token-else () (=satisfies #'token-else-p))
(defun =token-end () (=satisfies #'token-end-p))
(defun =token-loop () (=satisfies #'token-loop-p))
(defun =token-include () (=satisfies #'token-include-p))
(defun =token-insert () (=satisfies #'token-insert-p))

(defun =template-string ()
  (=let* ((token-string (=token-string)))
    (=result (att-string (token-str token-string)))))

(defun =control-variable ()
  (=let* ((token-variable (=token-variable)))
    (=result (att-variable (token-var token-variable)))))

(defun =control-if ()
  (=let* ((token-if (=token-if))
          (then     (=template))
          (else     (=maybe (=and (=token-else) (=template))))
          (_        (=token-end)))
    (=result (att-if (att-eval (token-cond-clause token-if))
                     then
                     (if else
                         (car else)
                         (att-nil))))))

(defun =control-loop ()
  (=let* ((token-loop (=token-loop))
          (body       (=template))
          (_          (=token-end)))
    (=result (att-loop
              (att-variable (token-seq token-loop))
              body
              (if (token-loop-sym token-loop)
                  (att-variable (token-loop-sym token-loop))
                  (att-gensym "loopvar"))))))

(defun =control-include ()
  (=let* ((token-include (=token-include)))
    (=result (att-string (token-include-string)))))

(defun =control-insert ()
  (=let* ((token-insert (=token-insert)))
    (=result (att-string (token-insert-string)))))


(defun =template ()
  (=let* ((tmp (=one-or-more
                (=or
                 (=template-string)
                 (=control-variable)
                 (=control-if)
                 (=control-loop)
                 (=control-include)
                 (=control-insert)))))
    (=result (apply #'att-progn tmp))))
