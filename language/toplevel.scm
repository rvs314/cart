(define-module (cart language toplevel)
  #:use-module (oop goops)
  #:use-module (cart oop contexts))

(define-syntax (cart stx) 
  (syntax-case ()
    [(cart rule ...)
     (with-new-context
      (cart-toplevel))]))

