(in-package :cl-user)
(defpackage zenekindarl.token
  (:use :cl
        :annot.class)
  (:export
   :token-string-p
   :token-variable-p
   :token-if-p
   :token-else-p
   :token-end-p
   :token-loop-p
   :token-repeat-p
   :token-include-p
   :token-insert-p))
(in-package zenekindarl.token)

(annot:enable-annot-syntax)

@export-accessors
(defstruct token
  (start 0 :type integer)
  (end 0 :type integer)
  (template))

@export
@export-accessors
@export-constructors
(defstruct (token-string
             (:conc-name token-)
             (:include token))
  (str "" :type string))

@export
@export-accessors
@export-constructors
(defstruct (token-variable
             (:conc-name token-)
             (:include token))
  (value nil :type (or null symbol))
  (auto-escape t :type boolean))

@export
@export-accessors
@export-constructors
(defstruct (token-if
             (:conc-name token-)
             (:include token))
  (cond-clause))

@export
@export-accessors
@export-constructors
(defstruct (token-else
             (:conc-name token-)
             (:include token)))

@export
@export-accessors
@export-constructors
(defstruct (token-end
             (:conc-name token-)
             (:include token)))


@export
@export-accessors
@export-constructors
(defstruct (token-loop
             (:conc-name token-)
             (:include token))
  (seq () :type (or list symbol))
  (loop-sym nil :type (or null symbol)))

@export
@export-accessors
@export-constructors
(defstruct (token-repeat
             (:conc-name token-)
             (:include token))
  (times () :type (or integer symbol))
  (repeat-sym nil :type (or null symbol)))

@export
@export-accessors
@export-constructors
(defstruct (token-include
             (:conc-name token-)
             (:include token))
  (include-template nil :type list))

@export
@export-accessors
@export-constructors
(defstruct (token-insert
             (:conc-name token-)
             (:include token))
  (insert-string "" :type string))

