(in-package :cl-user)
(defpackage zenekindarl.lexer.default
  (:use :cl
        :zenekindarl.util
        :zenekindarl.token
        :zenekindarl.lexer)
  (:import-from :alexandria
                :if-let
                :iota
                :read-file-into-string)
  (:export :lex))
(in-package zenekindarl.lexer.default)
(annot:enable-annot-syntax)


(defun read-out (str start eof-value)
  (multiple-value-bind (atom end)
      (read-from-string str nil eof-value :start start)
    (if-let ((i (and (symbolp atom)
                     (search "}}" str :start2 start :end2 end)))
             (*package* (find-package :zenekindarl.lexer.default)))
      (multiple-value-bind (atom end)
          (read-from-string str nil eof-value :start start :end i)
        (list t atom (+ end (length "}}"))))
      (list nil (if (symbolp atom) (intern (symbol-name atom) *package*)
                    atom)
            end))))

(defun tokenize-variable (start end rest)
  (let ((plist (cdr rest)))
    (make-token-variable :start start :end end :value (car rest)
			 :auto-escape (getf plist 'auto-escape t))))

(defun tokenize-if (start end rest)
  (make-token-if :start start :end end :cond-clause (car rest)))

(defun tokenize-else (start end rest)
  @ignore rest
  (make-token-else :start start :end end))

(defun tokenize-end (start end rest)
  @ignore rest
  (make-token-end :start start :end end))

(defun tokenize-loop (start end rest)
  (destructuring-bind (seq as var) rest
    @ignore as
    (make-token-loop :start start :end end
                     :seq seq :loop-sym var)))

(defun tokenize-repeat (start end rest)
  (if (= (length rest) 1)
      (make-token-repeat :start start :end end :times (car rest)) 
   (destructuring-bind (times as var) rest
     @ignore as
     (make-token-repeat :start start :end end :times times :repeat-sym var))))

(defun tokenize-include (start end rest)
  (make-token-include :start start :end end :include-template (lex (read-file-into-string (merge-pathnames (car rest))) :default)))

(defun tokenize-insert (start end rest)
  (make-token-insert :start start :end end :insert-string (read-file-into-string (merge-pathnames (car rest)))))

(defun tokenize (obj start end)
  (if (stringp obj)
      (make-token-string :start start :end end :str obj)
      (funcall (ecase (car obj)
                 ((var) #'tokenize-variable)
                 ((if) #'tokenize-if)
                 ((else) #'tokenize-else)
                 ((endif) #'tokenize-end)
                 ((loop) #'tokenize-loop)
                 ((endloop) #'tokenize-end)
                 ((repeat) #'tokenize-repeat)
                 ((endrepeat) #'tokenize-end)
                 ((include) #'tokenize-include)
                 ((insert) #'tokenize-insert))
               start end
               (cdr obj))))

(defun tokens (str start)
  (loop
     :with eof-value := '#:eof
     :for i := start :then end
     :for (endp atom end) := (read-out str i eof-value)
     :if (not (eq eof-value atom)) :collect atom :into result
     :until endp
     :finally (return (cons result end))))

(defmethod lex (str (lexer (eql :default)))
  (labels ((aux (start result)
             (let* ((end (search "{{" str :test #'char= :start2 start)))
               (if end
                   (let ((sub (tokenize (subseq str start end) start end))
                         (start (+ end 2)))
                     (destructuring-bind (atoms . end) (tokens str start)
                       (aux end (cons (tokenize atoms start end) (cons sub result)))))
                   (reverse (cons (tokenize (subseq str start) start (length str)) result))))))
    (aux 0 ())))

