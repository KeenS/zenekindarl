(in-package :cl-user)
(defpackage clta.parse
  (:use :cl :clta.util)
  (:import-from :cl-ppcre
                :quote-meta-chars
                :split)
  (:import-from :optima
                :match))
(in-package clta.parse)

(defvar *open-marker* "{{"
  "Start of scriptlet or expression. Remember that a following #\=
indicates an expression.")

(defvar *close-marker* "}}"
  "End of scriptlet or expression.")

(defstruct (token
             (:constructor make-token (str type lstart cstart lend cend)))
  (str "" :type string)
  (type :unknown :type keyword)
  (lstart 0 :type integer)
  (cstart 0 :type integer)
  (lend   0 :type integer)
  (cend   0 :type integer))

(defun analyze-location (str linestart columnstart)
  (let* ((lines (count #\Newline str))
         (column (if (plusp lines)
                     (- (length str) (1+ (position #\Newline str :from-end t)))
                     (length str))))
    (values (+ lines linestart)
            (+ column columnstart))))

(defun simple-split (str)
  (coerce (split `(:register
            (:alternation
             ,*start-marker*
             ,*end-marker*))
          str
          :with-registers-p t)
          '(simple-array string (*))))

(defun annotate (tokens)
  (let ((lstart 0)
        (cstart 0)
        (new-tokens (make-array (length tokens)
                                :element-type 'token
                                :initial-element (make-token "" :unknown 0 0 0 0)))
        str
        type)
    (dotimes (i (length tokens))
      (setf str (aref tokens i))
      (setf type (cond
                   ((string= str *open-marker*)  :open-marker)
                   ((string= str *close-marker*) :close-marker)
                   (:otherwise                   :string)))
      (multiple-value-bind (lend cend) (analyze-location str lstart cstart)
        (setf (aref new-tokens i) (make-token str type lstart cstart lend cend))
        (setf lstart lend
              cstart cend))))
  tokens)

(defun check-paired (tokens)
  )
