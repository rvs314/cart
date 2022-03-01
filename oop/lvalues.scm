(define-module (cart oop lvalues)
  #:use-module (oop goops)
  #:use-module (shorthand ffi)
  #:use-module (shorthand oop)
  #:use-module (shorthand syntax)
  #:use-module (shorthand io)
  #:use-module (cart libgccjit enums)
  #:use-module (cart libgccjit bindings)
  #:use-module (cart oop contexts)
  #:use-module (cart oop objects)
  #:use-module (cart oop types)
  #:use-module (cart oop rvalues)
  #:use-module (cart oop locations)
  #:duplicates (merge-generics))

(define-struct (<lvalue> <rvalue>))

(export <lvalue>)

(define-method (->object (obj <lvalue>))
  (make-in-context <cart-object>
                   (lvalue->object (->pointer (->lvalue obj)))))

(define-method (->rvalue (obj <lvalue>))
  (make-in-context <rvalue>
                   (lvalue->rvalue (->pointer (->lvalue obj)))))

(define-method (->lvalue (obj <lvalue>))
  obj)

(define-syntax-rule (->lvalue! obj ...)
  (begin (set! obj (->lvalue obj))
         ...))

(export ->lvalue ->lvalue! <lvalue>)

(define-struct (<reference> <rvalue>))

(define-method (reference-to (obj <lvalue>) location)
  (->lvalue! obj)
  (->pointer! obj location)
  (lvalue-get-address obj location))

(define* (reference obj #:key (location (%current-location)))
  (make-in-context <reference>
                   (reference-to obj location)))
(export <reference> reference-to reference)
  
(define-struct (<global> <lvalue>))  

(define* (global type name #:key imported? exported? initial-blob (location (%current-location)))
  (define kind
    (cond [imported? GLOBAL-IMPORTED]
          [exported? GLOBAL-EXPORTED]
          [else      GLOBAL-INTERNAL]))
  (define p
    (context-new-global
     (current-context-pointer)
     (->pointer location)
     kind
     (->pointer type)
     (->pointer (->string name))))
  (when initial-blob
    (global-set-initializer p (pointer initial-blob) (size initial-blob)))
  (make-in-context <global> p))

(export <global> global)

(define-struct (<dereference> <lvalue>))

(define* (dereference obj #:key (location (%current-location)))
  (make-in-context <dereference>
                   (rvalue-dereference (->pointer (->rvalue obj))
                                       (->pointer location))))

(export <dereference> dereference) 

(define-struct (<field-access> <lvalue>))
(define-struct (<field-read> <rvalue>))

(define* (field-access obj field #:key (location (%current-location)))
  (define-values (class fn obj)
    (if (is-a? obj <lvalue>)
        (values <field-access> lvalue-access-field (->lvalue obj))
        (values <field-read> rvalue-access-field (->rvalue obj))))
  (make-in-context class
                   (fn (->pointer obj)
                       (->pointer location)
                       (->pointer field))))

(export <field-access> <field-read> field-access)

(define-struct (<array-access> <lvalue>))

(define* (array-access arr index #:key (location (%current-location)))
  (->rvalue! arr index)
  (make-in-context <array-access>
                   (context-new-array-access
                    (current-context-pointer)
                    (->pointer location)
                    (->pointer arr)
                    (->pointer index))))
  
(export <array-access> array-access)
