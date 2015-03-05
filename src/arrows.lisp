#|
This file is a part of arrows project.
Copyright (c) 2014 κeen
|#

(in-package :cl-user)
(defpackage arrows
  (:use
   :cl
   :arrows.parse
   :arrows.pass
   :arrows.backend
   :arrows.backend.stream
   :arrows.backend.sequence
   :arrows.backend.fast-io
   :arrows.util)
  (:import-from :alexandria
                :read-file-into-string)
  (:export :compile-template-string
           :compile-template-file
           :render
           :render-file))
(in-package :arrows)

(defun compile-template-string (backend str env)
  (emit-lambda (if (keywordp backend)
                   (make-backend backend)
                   (apply #'make-backend backend))
               (apply-passes (parse-template-string str) env)))

(defun compile-template-file (backend file env)
  (compile-template-string backend (read-file-into-string file) env))

(defun render (template &rest args)
  (let* ((backend-given (getf args :backend))
         (backend (or backend-given :stream)))
    (when backend-given
      (remf args :backend))
    (apply (compile-template-string backend template ())
           (if backend-given
               args
               (cons *standard-output* args)))))

(defun render-file (template-file &rest args)
  (apply #'render (read-file-into-string template-file) args))


#+(or)
(render "Hello {{var name}}!!"
        :name "κeen")

#+(or)
(let ((renderer (compile-template-string :stream "Hello {{var name}}!!" ())))
  (funcall renderer *standard-output* :name "κeen"))

