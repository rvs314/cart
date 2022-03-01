(define-module (cart language compile)
  #:use-module (cart oop objects))

;; There are two possible ways to do scoping:
;; - Guile can (with some hacking) create empty modules: modules which
;; do not contain any builtin definitions aside from number and string literals.
;; This essentially allows us to define new values for primitives

  
