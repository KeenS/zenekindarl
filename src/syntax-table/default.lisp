(in-package :cl-user)
(defpackage clta.syntax-table.default
  (:use :cl
        :esrap
        :clta.att
        :clta.syntax-table)
  (:import-from :alexandria
               :read-file-into-string
               :iota)
  (:export :template
           :control-if
           :control-var))

(in-package clta.syntax-table.default)

(defrule integer (+ (or "0" "1" "2" "3" "4" "5" "6" "7" "8" "9"))
  (:lambda (list)
    (parse-integer (text list) :radix 10)))

(defrule template
    (* (or control template-string))
  (:lambda (tmpl)
    (apply #'att-progn tmpl)))

(defrule symbol-in-control
    (+ (not (or "}}" white-space)))
  (:text t))

(defmarkers default "{{" "}}")

(defcontrol control-if
    (and op-if
         template
         (? (and op-else template))
         op-endif)
  (:destructure (cond then (&optional op/else  (else (att-nil))) op/endif)
                (declare (ignore op/else op/endif))
                (att-if cond then else)))

(defcontrol control-var
    op-var)

(defcontrol control-repeat
  (and op-repeat
       template
       op-endrepeat)
  (:destructure ((seq var) tmp op/endrepeat)
                (declare (ignore op/endrepeat))
                (att-loop seq tmp var)))

(defcontrol control-loop
  (and op-loop template op-endloop)
  (:destructure ((var seq) tmp op/endloop)
                (declare (ignore op/endloop))
                (att-loop seq tmp var)))

(defcontrol control-include op-include)
;; (defcontrol set op-set)
(defcontrol control-insert op-insert)



(defop op-if (and "if" white-spaces symbol-in-control)
    :transform
  (lambda (op space sym)
    (declare (ignore op space))
    (att-variable (read-from-string sym))))

(defop op-else "else")
(defop op-endif "endif")


(defop op-var (and "var" white-spaces symbol-in-control)
    :transform
    (lambda (op space sym)
      (declare (ignore op space))
      (att-output (att-variable (read-from-string sym)))))


(defop op-repeat (and "repeat" white-spaces integer (? (and white-spaces "as" white-spaces symbol-in-control)))
  :transform (lambda (op sp1 i &optional optional-exp)
               (declare (ignore op sp1))
               (if optional-exp
                   (destructuring-bind (sp2 op2 sp3 var) optional-exp
                     (declare (ignore sp2 sp3 op2))
                     (list (att-constant (iota i :start 1))
                           (att-variable (read-from-string var))))
                   (list (att-constant (iota i :start 1))
                         (att-variable (gensym "repeatvar"))))))

(defop op-endrepeat "endrepeat")


(defop op-loop (and "loop" white-spaces symbol-in-control white-spaces "as" white-spaces symbol-in-control)
  :transform (lambda (ign1 sp1 seq sp2 ign2 sp3 var)
               (declare (ignore ign1 ign2 sp1 sp2 sp3))
               (list (att-variable (read-from-string var))
                     (att-variable (read-from-string seq)))))

(defop op-endloop "endloop")


(defop op-include (and "include" white-spaces symbol-in-control)
  :transform (lambda (op sp filename)
               (declare (ignore op sp))
               (parse 'template (read-file-into-string (merge-pathnames filename)))))


;; (defop op-set (and "set" white-spaces symbol-in-control white-spaces symbol-in-control)
;;   :transform (lambda (op sp1 var sp2 val)
;;                (declare (ignore op sp1 sp2))
;;                (att-strin)))


(defop op-insert (and "insert" white-spaces symbol-in-control)
  :transform (lambda (op sp filename)
               (declare (ignore op sp))
               (att-output (att-string (read-file-into-string (merge-pathnames filename))))))
