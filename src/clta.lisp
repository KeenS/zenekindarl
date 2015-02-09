#|
  This file is a part of clta project.
  Copyright (c) 2014 κeen
|#

(in-package :cl-user)
(defpackage clta
  (:use
   :cl
   :clta.parse
   :clta.pass
   :clta.backend
   :clta.backend.stream
   :clta.util)
  (:import-from :alexandria
                :if-let)
  (:export :compile-template-string
           :render))
(in-package :clta)

(defun compile-template-string (backend str env)
  (let* ((code (emit-code backend (apply-passes (parse-template-string str) env)))
         (syms (symbols backend)))
    (eval
     `(lambda ,(if syms `(&key ,@syms) ())
        ,code
        t))))

(defun render (template &rest args)
  (let  ((backend (or (getf args :backend) (make-backend :stream :stream '*standard-output*))))
   (apply (complie-template-string backend template '(:known-args (:name "κeen"))) args)))


#+(or)
(render "Hello {{var name}}!!"
        :name "κeen")
