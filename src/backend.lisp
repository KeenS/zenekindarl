#|
This file is a part of arrows project.
Copyright (c) 2014 κeen
|#

(in-package :cl-user)
(defpackage arrows.backend
  (:use :cl :arrows.util :arrows.att)
  (:import-from :html-encode
   :encode-for-tt)
  (:export :backend
   :make-backend
           :emit-code
   :emit-lambda
           :emit-parameters
   :symbols))

(in-package :arrows.backend)

(defclass backend ()
  ((symbols
    :accessor symbols
    :initform ())
   (scopes
    :accessor scopes
    :initform ())))

(defgeneric make-backend (backend &key &allow-other-keys))

(defgeneric push-scope (backend)
  (:method (backend)
    (push () (scopes backend))))
(defgeneric pop-scope (backend)
  (:method (backend)
    (pop (scopes backend))))

(defgeneric add-to-scope (sym backend)
  (:method (sym backend)
    (push sym (car (scopes backend)))))
(defgeneric find-from-scope (sym backend)
  (:method (sym backend)
    (loop :for scope :in (scopes backend)
            :thereis (member sym scope))))

(defgeneric http-escape (obj sexp)
  (:method (obj sexp)
    (declare (ignore obj))
    (error "Don't know how to escape ~a" sexp))
  (:method ((obj att-leaf) sexp)
    (declare (ignore obj))
    `(encode-for-tt (princ-to-string ,sexp))))

(defgeneric emit-code (backend obj &key output-p)
  (:method (backend obj &key output-p)
    (declare (ignore output-p))
    (error "The backend ~A of ~A is not implemented" backend obj)))

(defmethod emit-code :around (backend (obj att-leaf) &key output-p)
  (if (and output-p (auto-escape obj))
      (http-escape obj (call-next-method backend obj))
      (call-next-method backend obj)))
;;; You are to implement the backend specific `emit-code' for `att-output'
;; (defmethod emit-code (backend (obj att-output)))

(defmethod emit-code (backend (obj att-string) &key output-p)
  (declare (ignore backend output-p))
  (value obj))

(defmethod http-escape ((obj att-string) sexp)
  (declare (ignore obj))
  (encode-for-tt sexp))

(defmethod emit-code (backend (obj att-variable) &key output-p)
  (declare (ignore output-p))
  (let ((sym (varsym obj)))
    (unless (find-from-scope sym backend)
      (push sym (symbols backend)))
    sym))

(defmethod http-escape ((obj att-variable) sexp)
  (declare (ignore obj))
  (if (eq (vartype obj) :string)
      `(encode-for-tt ,sexp)
      (call-next-method obj sexp)))

(defmethod emit-code (backend (obj att-constant) &key output-p)
  (declare (ignore backend output-p))
  `',(value obj))

(defmethod emit-code (backend (obj att-eval) &key output-p)
  (declare (ignore backend output-p))
  (sexp obj))

(defmethod emit-code (backend (obj att-nil) &key output-p)
  (declare (ignore backend obj output-p))
  nil)

(defmethod emit-code (backend (obj att-progn) &key output-p)
  (cons 'progn (mapcar (lambda (node)
                         ;; :FIXME: mark output-p only the last one
                         (emit-code backend node :output-p output-p))
                       (nodes obj))))

(defmethod emit-code (backend (obj att-if) &key output-p)
  (with-slots (cond-clause then-clause else-clause) obj
    (list 'if
          (emit-code backend cond-clause)
          (emit-code backend then-clause :output-p output-p)
          (emit-code backend else-clause :output-p output-p))))

(defmethod emit-code (backend (obj att-loop) &key output-p)
  (with-slots (loop-seq body loop-var) obj
    (let* ((seq (emit-code backend loop-seq))
           (sym (varsym loop-var)))
      (push-scope backend)
      (add-to-scope sym backend)
      `(loop
         ;; :FIXME: dirty hack
         :for ,sym
           :in ,seq
         :do ,(emit-code backend body :output-p output-p)))))

(defgeneric emit-parameters (backend)
  (:method (backend)
    (let ((syms (symbols backend)))
      (if syms `(&key ,@syms) ()))))

(defgeneric emit-lambda (backend att)
  (:method (backend att)
    (let* ((code (emit-code backend att)))
      (eval
       `(lambda ,(emit-parameters backend)
          ,code
          t)))))
