(define-module (cart oop rvalues)
  #:use-module (oop goops)
  #:use-module (shorthand ffi)
  #:use-module (shorthand oop)
  #:use-module (shorthand syntax)
  #:use-module (cart libgccjit enums)
  #:use-module (cart libgccjit bindings)
  #:use-module (cart oop contexts)
  #:use-module (cart oop objects)
  #:use-module (cart oop types)
  #:use-module (cart oop functions)
  #:use-module (cart oop locations)
  #:duplicates (merge-generics))

(define-struct (<rvalue> <cart-object>))

(export <rvalue>)

(define-method (->rvalue (obj <rvalue>))
  obj)

(define-syntax-rule (->rvalue! obj ...)
  (begin (set! obj (->rvalue obj))
         ...))

(define-method (type-of (obj <rvalue>))
  (->rvalue! obj)
  (make-in-context <type>
                   (rvalue-get-type
                          (pointer obj))))

(define-method (->object (obj <rvalue>))
  (->rvalue! obj)
  (make-in-context <cart-object>
                   (rvalue->object (->pointer obj))))

(export ->rvalue ->rvalue! type-of ->object)

(define-struct (<literal> <rvalue>))

(define-child-structs <literal>
  <number-literal>
  <pointer-literal>
  <string-literal>
  <vector-literal>)

(define-public (number-literal type val) 
  "Returns a number literal of the given type"
  (make-in-context <number-literal>
                  (build-number
                   (->pointer type)
                   val)))

(define-method (build-number type* (val <integer>))
  (context-new-rvalue-from-long
   (current-context-pointer)
   type*
   val))

(define-method (build-number type* (val <real>))
  (set! val (exact->inexact val))
  (context-new-rvalue-from-double
   (current-context-pointer)
   type*
   val))

(define-public (pointer-literal type value)
  "Returns a pointer literal"
  (make-in-context <pointer-literal>
    (context-new-rvalue-from-ptr
       (current-context-pointer)
       (pointer type)
       value)))

(define-public (string-literal value)
  "Returns a NULL-terminated string literal"
  (make-in-context <string-literal>
                   (context-new-string-literal
                    (current-context-pointer)
                    (->pointer value))))

(define* (vector-literal #:key (location (%current-location)) item-type #:rest items)
  "Returns a vector literal: all items should be of the same type, which
   is the type of 'item-type' if provided"
  (define type
    (cond [item-type item-type]
          [(pair? items) (type-of (car items))]
          [else (error "vector-literal requires either an item-type or a non-empty list of items")]))
  (define item-array
    (apply allocate-array ptr
           (map (lambda (a) (->pointer (->rvalue a))) items)))
  (define num-items (length items))
  (make-in-context <vector-literal>
                   (context-new-rvalue-from-vector
                    (current-context-pointer)
                    (->pointer location)
                    (type-get-vector (->pointer type)
                                     num-items)
                    num-items
                    item-array)))

(export vector-literal)

(define-struct (<unary-op> <rvalue>))

(define-child-structs <unary-op>
  <arithmetic-negation>
  <bitwise-negation>
  <logical-negation>
  <absolute-value>)

(export <unary-op>
  <arithmetic-negation>
  <bitwise-negation>
  <logical-negation>
  <absolute-value>)

(define (unop class enum)
  (lambda* (value result-type #:key (location (%current-location)))
    (->rvalue! value)
    (make-in-context class
                     (context-new-unary-op
                      (current-context-pointer)
                      (->pointer location)
                      enum
                      (->pointer result-type)
                      (->pointer (->rvalue value))))))

(define-all public
  arithmetic-negation (unop <arithmetic-negation> UNARY-OP-MINUS)
  bitwise-negation (unop <bitwise-negation> UNARY-OP-BITWISE-NEGATE)
  logical-negation (unop <logical-negation> UNARY-OP-LOGICAL-NEGATE)
  absolute-value (unop <absolute-value> UNARY-OP-ABS))

(define-struct (<binary-op> <rvalue>))

(define-child-structs <binary-op>
  <addition> <subtraction>
  <multiplication> <division> <modulous>
  <bitwise-and> <bitwise-or> <bitwise-xor>
  <logical-and> <logical-or>
  <left-shift> <right-shift>)

(export <binary-op>
  <addition> <subtraction>
  <multiplication> <division> <modulous>
  <bitwise-and> <bitwise-or> <bitwise-xor>
  <logical-and> <logical-or>
  <left-shift> <right-shift>)

(define (binop class enum)
  (lambda* (left right result-type #:key (location (%current-location)))
    (->rvalue! left right)
    (make-in-context class
                     (context-new-binary-op
                      (current-context-pointer)
                      (->pointer location)
                      enum
                      (->pointer result-type)
                      (->pointer (->rvalue left))
                      (->pointer (->rvalue right))))))

(define-all public
  addition (binop <addition> BINARY-OP-PLUS)
  subtraction (binop <subtraction> BINARY-OP-MINUS)
  multiplication (binop <multiplication> BINARY-OP-MULT)
  division (binop <division> BINARY-OP-DIVIDE)
  modulous (binop <modulous> BINARY-OP-MODULO)
  bitwise-and (binop <bitwise-and> BINARY-OP-BITWISE-AND)
  bitwise-or (binop <bitwise-or> BINARY-OP-BITWISE-OR)
  bitwise-xor (binop <bitwise-xor> BINARY-OP-BITWISE-XOR)
  logical-and (binop <logical-and> BINARY-OP-LOGICAL-AND)
  logical-or (binop <logical-or> BINARY-OP-LOGICAL-OR)
  left-shift (binop <left-shift> BINARY-OP-LSHIFT)                  
  right-shift (binop <right-shift> BINARY-OP-RSHIFT))                  

(define-struct (<comparison> <rvalue>))

(define-child-structs <comparison>
  <equal-to> <not-equal-to>
  <less-than> <less-than-or-equal-to>
  <greater-than> <greater-than-or-equal-to>)

(export <comparison>
        <equal-to> <not-equal-to>
        <less-than> <less-than-or-equal-to>
        <greater-than> <greater-than-or-equal-to>)

(define (comparison class enum)
  (lambda* (left right #:key (location (%current-location)))
    (make-in-context class
                     (context-new-comparison
                      (current-context-pointer)
                      (->pointer location)
                      enum
                      (->pointer (->rvalue left))
                      (->pointer (->rvalue right))))))

(define-all public
  equal-to (comparison <equal-to> COMPARISON-EQ)
  not-equal-to (comparison <not-equal-to> COMPARISON-NE)
  less-than (comparison <less-than> COMPARISON-LT)
  less-than-or-equal-to (comparison <less-than-or-equal-to> COMPARISON-LE)
  greater-than (comparison <greater-than> COMPARISON-GT)
  greater-than-or-equal-to (comparison <greater-than-or-equal-to> COMPARISON-GE))

(define-struct (<function-call> <rvalue>))

(define* (function-call fn args #:key (location (%current-location)) tail-call?)
  (define num-args (length args))
  (define arg-array
    (apply allocate-array ptr
           (map (lambda (arg) (->pointer (->rvalue arg))) args)))
  (define function-kind
    (cond [(is-a? fn <rvalue>)
           (begin
             (->rvalue! fn)
             context-new-call-through-ptr)]
          [(is-a? fn <function>) context-new-call]))
  (define fn* (function-kind
               (current-context-pointer)
               (->pointer location)
               (->pointer fn)
               num-args
               arg-array))
  (rvalue-set-bool-require-tail-call fn* (boolean->integer tail-call?))
  (make-in-context <function-call>
                   fn*))

(export <function-call> function-call)

(define-struct (<cast> <rvalue>))

(define* (cast value type #:key (location (%current-location)))
  (make-in-context <cast>
                   (context-new-cast
                    (current-context-pointer)
                    (->pointer location)
                    (->pointer value)
                    (->pointer type))))

(export cast <cast>)

