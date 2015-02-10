#|
  This file is a part of clta project.
  Copyright (c) 2014 κeen
|#

(in-package :cl-user)
(defpackage clta.backend
  (:use :cl :clta.util :clta.att)
  (:export :backend
           :make-backend
           :emit-code
           :symbols))

(in-package :clta.backend)

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

(defgeneric emit-code (backend obj)
  (:method (backend obj)
      (error "The backend ~A of ~A is not implemented" backend obj)))

;;; You are to implement the backend specific `emit-code' for `att-output'
;; (defmethod emit-code (backend (obj att-output)))

(defmethod emit-code (backend (obj att-string))
  (declare (ignore backend))
  (value obj))

(defmethod emit-code (backend (obj att-variable))
  (let ((sym (varsym obj)))
    (unless (find-from-scope sym backend)
      (push sym (symbols backend)))
    sym))

(defmethod emit-code (backend (obj att-constant))
  (declare (ignore backend))
  `',(value obj))

(defmethod emit-code (backend (obj att-eval))
  (declare (ignore backend))
  (sexp obj))

(defmethod emit-code (backend (obj att-nil))
  (declare (ignore backend obj))
  nil)

(defmethod emit-code (backend (obj att-progn))
  (cons 'progn (mapcar (lambda (node)
                            (emit-code backend node))
                       (nodes obj))))

(defmethod emit-code (backend (obj att-if))
  (with-slots (cond-clause then-clause else-clause) obj
    (list 'if
          (emit-code backend cond-clause)
          (emit-code backend then-clause)
          (emit-code backend else-clause))))

(defmethod emit-code (backend (obj att-loop))
  (with-slots (loop-seq body loop-var) obj
    (let* ((seq (emit-code backend loop-seq))
           (sym (varsym loop-var)))
      (push-scope backend)
      (add-to-scope sym backend)
      `(loop
         ;; :FIXME: dirty hack
         :for ,sym
         :in ,seq
         :do ,(emit-code backend body)))))
