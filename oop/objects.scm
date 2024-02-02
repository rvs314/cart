(define-module (cart oop objects)
  #:use-module (oop goops)
  #:use-module (ice-9 exceptions)
  #:use-module (system foreign)
  #:use-module (shorthand oop)
  #:use-module (shorthand ffi)
  #:use-module (cart libgccjit bindings)
  #:use-module (cart libgccjit enums)
  #:use-module (cart oop contexts)
  #:duplicates (merge-generics)
  #:re-export (->pointer)
  #:export (->object <cart-object>))

(define-struct (<cart-object> <wrapped-pointer>) context)

(export <cart-object> context)

(define-public (make-in-context class pointer)
  (make class
    #:pointer pointer
    #:context %current-context))

(define-method (->pointer (obj <cart-object>))
  (pointer obj))

(define-method (->object (obj <cart-object>))
  obj)


(define-syntax-rule (->object! obj)
  (begin (set! obj (->object obj))))
        
(define-method (show (obj <cart-object>))
  (define p (->pointer (->object obj)))
  (format (current-output-port) "#<cart ~a '~a' at 0x~x>~%"
          (class-name (class-of obj))
          (pointer->string (object-get-debug-string p))
          (pointer-address p)))

(export show)
