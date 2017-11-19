(in-package :cl-user)
(defpackage :zenekindarl.parser
  (:use :cl :zenekindarl.util :zenekindarl.token :zenekindarl.att :maxpc)
  (:export :=template))
(in-package :zenekindarl.parser)

(defun id (prop) (=transform (=subseq (?satisfies prop)) #'car))
(defun ?token-string () (id #'token-string-p))
(defun ?token-variable () (id #'token-variable-p))
(defun ?token-if () (id #'token-if-p))
(defun ?token-else () (id #'token-else-p))
(defun ?token-end () (id #'token-end-p))
(defun ?token-loop () (id #'token-loop-p))
(defun ?token-repeat () (id #'token-repeat-p))
(defun ?token-include () (id #'token-include-p))
(defun ?token-insert () (id #'token-insert-p))



(defun =template-string ()
  (=destructure (token-string) (=list (?token-string))
    (att-output (att-string (token-str token-string)))))

(defun =control-variable ()
  (=destructure (token-variable) (=list (?token-variable))
    (att-output (att-variable (token-value token-variable)
			      :anything
			      (token-auto-escape token-variable)))))

(defun =control-if ()
  (=destructure (token-if then else _)
      (=list (?token-if) 's/=template (%maybe (%and (?token-else) 's/=template)) (?token-end))
    (att-if (if (symbolp (token-cond-clause token-if))
                (att-variable (token-cond-clause token-if))
                (att-eval (token-cond-clause token-if)))
            then
            (if else
                else
                (att-nil)))))

(defun =control-loop ()
  (=destructure (token-loop body _) (=list (?token-loop) 's/=template (?token-end))
    (att-loop
     (if (symbolp (token-seq token-loop))
         (att-variable (token-seq token-loop))
         (att-constant (token-seq token-loop)))
     body
     (if (token-loop-sym token-loop)
         (att-variable (token-loop-sym token-loop))
         (att-gensym "loopvar")))))

(defun =control-repeat ()
  (=destructure (token-repeat body _) (=list (?token-repeat) 's/=template (?token-end))
    (att-repeat
     (if (symbolp (token-times token-repeat))
         (att-variable (token-times token-repeat))
         (att-constant (token-times token-repeat)))
     body
     (if (token-repeat-sym token-repeat)
         (att-variable (token-repeat-sym token-repeat))
         (att-gensym "repeatvar")))))

(defun =control-include ()
  (=destructure (token-include) (=list (?token-include))
    (parse (token-include-template token-include) 's/=template)))

(defun =control-insert ()
  (=destructure (token-insert) (=list (?token-insert))
    (att-output (att-string (token-insert-string token-insert)))))


(defun =template ()
  (=destructure (tmp) (=list (%some
                        (%or
                         (=template-string)
                         (=control-variable)
                         (=control-if)
                         (=control-loop)
                         (=control-repeat)
                         (=control-include)
                         (=control-insert))))
    (apply #'att-progn tmp)))
(setf (fdefinition 's/=template) (=template))
