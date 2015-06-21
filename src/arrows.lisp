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

(defun compile-template-string (backend str &key (syntax :default) (env ()))
  "compiles `str' with `env' and emmit renderer with backend `backend'.
`backend': Currently, one of :stream :octet-stream :string :octets :fast-io.
`str': A template string.
`syntax': Currently, :default only.
`env': A plist of compile time information. Left nil.
return: A keyword argumented lambda.
        If the backend is :stream or :octet-stream, it looks like (lambda (stream &key ...) ...).
        If the backend is :string or :octets, it looks like (lambda (&key ...) ...).
        If the backend is :fast-io, it looks like (lambda (fast-io-buffer &key ...) ...).
        Keys are free variables appear in the template."

  (emit-lambda (if (keywordp backend)
                   (make-backend backend)
                   (apply #'make-backend backend))
               (apply-passes (parse-template-string str syntax) env)))

(defun compile-template-file (backend file &key (syntax :default) (env ()))
  "Read `file' into string and passes `compile-template-string'"
  (compile-template-string backend (read-file-into-string file) :syntax syntax :env env))

(defun render (template &rest args)
  "Parse template and render it with args. Like below:
(render \"Hello {{var name}}!!\" :name \"κeen\")
(render \"Hello {{var name}}!!\" :backend :octet-stream stream :name \"κeen\")
.
If args have `:backend backend' key-value pair, this function uses it. If not given the backend is :stream and stream is *standard-output*.
And also if `:syntax syntax' is given, use it or default to :default. "
  (let* ((backend-given (getf args :backend))
         (backend (or backend-given :stream))
         (syntax-given (getf args :syntax))
         (syntax (or syntax-given :default)))
    (when backend-given
      (remf args :backend))
    (when syntax-given
      (remf args :syntax))
    (apply (compile-template-string backend template :syntax syntax)
           (if backend-given
               args
               (cons *standard-output* args)))))

(defun render-file (template-file &rest args)
  "A wrapper of `render'"
  (apply #'render (read-file-into-string template-file) args))


#+(or)
(render "Hello {{var name}}!!" :name "κeen")

#+(or)
(let ((renderer (compile-template-string :stream "Hello {{var name}}!!")))
  (funcall renderer *standard-output* :name "κeen"))

