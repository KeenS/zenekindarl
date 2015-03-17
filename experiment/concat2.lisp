(declaim (ftype (function (list) string)
                cat-with-stream
                cat-with-stream2
                cat-with-stream3
                cat-with-concatenate))

(defun cat-with-concatenate (list)
  (declare (optimize (speed 3) (space 0) (safety 0) (debug 0)))
  (apply #'concatenate 'string list))

(defun cat-with-stream (list)
  (declare (optimize (speed 3) (space 0) (safety 0) (debug 0)))
  (with-output-to-string (sstream)
    (loop for str in list do (princ str sstream)) ))

(defun cat-with-stream2 (list)
  (declare (optimize (speed 3) (space 0) (safety 0) (debug 0)))
  (with-output-to-string (sstream)
    (loop for str in list do (write-sequence str sstream)) ))

(defun cat-with-stream3 (list)
  (declare (optimize (speed 3) (space 0) (safety 0) (debug 0)))
  (with-output-to-string (sstream)
    (loop for str in list do (write-string str sstream)) ))

(eval-when (:execute)
  (defvar input-list nil)
  (setq input-list (loop for i from 1  to 255 collect (write-to-string i)))
  
  (let ((*trace-output* *standard-output*))
    (time (dotimes (_ 100) (cat-with-concatenate input-list)))
    (time (dotimes (_ 100) (cat-with-stream input-list)))
    (time (dotimes (_ 100) (cat-with-stream2 input-list)))
    (time (dotimes (_ 100) (cat-with-stream3 input-list)))))

