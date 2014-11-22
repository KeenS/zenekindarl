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

(defun complie-template-string (backend str)
  (let ((code (emit-code backend (remove-progn-pass (append-sequence-pass (flatten-pass (parse-template-string str))))))
        (syms (symbols backend)))
    `(lambda ,(if syms `(&key ,@syms) ())
       ,code
       t)))

(defun render (template &rest args )
  (let  ((backend (or (getf args :backend) (make-instance 'stream-backend :stream '*standard-output*))))
   (eval `(,(complie-template-string backend template) ,@args))))


#+(or)
(render (make-instance 'stream-backend :stream '*standard-output*)
        "Hello {{var name}}!!"
        :name "κeen")
