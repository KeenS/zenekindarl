(in-package :cl-user)
(defpackage clta.parser
  (:use :cl
        :clta.att)
  (:import-from :split-sequence
                :split-sequence)
  (:import-from :alexandria
                :if-let))
(in-package clta.parser)


(defun read-out (str start)
  (multiple-value-bind (atom end)
      (read-from-string str t nil :start start)
    (if-let ((i (and (symbolp atom)
                     (search "}}" str :start2 start :end2 end))))
      (multiple-value-bind (atom end)
          (read-from-string str t nil :start start :end i)
        (list t atom (+ end (length "}}"))))
      (list nil atom end))))

(defun tokens (str start)
  (loop
     :for i := start :then end
     :for (endp atom end) := (read-out str i)
     :collect atom :into result
     :until endp
     :finally (return (cons result end))))

(defun lex (str)
  (labels ((aux (start result)
             (let* ((end (search "{{" str :test #'char= :start2 start)))
               (if end
                   (let ((sub (subseq str start end)))
                     (destructuring-bind (atoms . end) (tokens str (+ end 2))
                       (aux end (cons atoms (cons sub result)))))
                   (reverse (cons (subseq str start) result))))))
    (aux 0 ())))

