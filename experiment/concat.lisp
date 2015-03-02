(declaim (ftype (function (list) string)
                cat-with-concatenate cat-with-stream ))

(defun cat-with-concatenate (list)
  (declare (optimize (speed 3) (space 0) (safety 0) (debug 0)))
  (flet ((strcat (x y)
           (declare (string x y)
                    (ftype (function (string string) string))
                    (optimize (speed 3) (space 0) (safety 0) (debug 0)) )
           (concatenate 'string x y) ))
    (reduce #'strcat (cdr list) :initial-value (car list)) ))

(defun cat-with-stream (list)
  (declare (optimize (speed 3) (space 0) (safety 0) (debug 0)))
  (with-output-to-string (sstream)
    (loop for str in list do (princ str sstream)) ))

(eval-when (:execute)
  (defvar input-list nil)
  (setq input-list (loop for i from 1 to 1000 collect (write-to-string i)))
  
  (let ((*trace-output* *standard-output*))
    (time (dotimes (_ 100) (cat-with-concatenate input-list)))
    (time (dotimes (_ 100) (cat-with-stream input-list))) ))


