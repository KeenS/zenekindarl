(in-package :cl-user)
(defpackage arrows.lexer.default
  (:use :cl
        :arrows.util
        :arrows.token
        :arrows.lexer)
  (:import-from :alexandria
                :if-let
                :iota
                :read-file-into-string)
  (:export :lex))
(in-package arrows.lexer.default)
(annot:enable-annot-syntax)


(defun read-out (str start)
  (multiple-value-bind (atom end)
      (read-from-string str nil nil :start start)
    (if-let ((i (and (symbolp atom)
                     (search "}}" str :start2 start :end2 end)))
             (*package* (find-package :arrows.lexer.default)))
      (multiple-value-bind (atom end)
          (read-from-string str nil nil :start start :end i)
        (list t atom (+ end (length "}}"))))
      (list nil (if (symbolp atom) (intern (symbol-name atom) *package*)
                    atom)
            end))))

(defun tokenize-variable (start end rest)
  (make-token-variable :start start :end end :value (car rest)))

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
      (make-token-loop :start start :end end :seq (iota (car rest) :start 1)) 
   (destructuring-bind (seq as var) rest
     @ignore as
     (make-token-loop :start start :end end :seq (iota seq :start 1) :loop-sym var))))

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
     :for i := start :then end
     :for (endp atom end) := (read-out str i)
     :if atom :collect atom :into result
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

