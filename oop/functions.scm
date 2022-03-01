(define-module (cart oop functions)
  #:use-module (oop goops)
  #:use-module (system foreign)
  #:use-module (shorthand ffi)
  #:use-module (shorthand oop)
  #:use-module (shorthand io)
  #:use-module (shorthand syntax)
  #:use-module (cart libgccjit enums)
  #:use-module (cart libgccjit bindings)
  #:use-module (cart oop contexts)
  #:use-module (cart oop objects)
  #:use-module (cart oop types)
  #:use-module (cart oop lvalues)
  #:use-module (cart oop rvalues)
  #:use-module (cart oop locations)
  #:duplicates (merge-generics))

(define-struct (<param> <lvalue>))

(define-method (->lvalue (obj <param>))
  (make-in-context <lvalue>
                   (param->lvalue (->pointer obj))))

(define-method (->rvalue (obj <param>))
  (make-in-context <rvalue>
                   (param->rvalue (->pointer obj))))

(define-method (->object (obj <param>))
  (make-in-context <object>
                   (param->object (->pointer obj))))

(define* (param type name #:key (location (%current-location)))
  (make-in-context <param>
                   (context-new-param (current-context-pointer)
                                      (->pointer location)
                                      (->pointer type)
                                      (->pointer (->string name)))))

(export <param> ->lvalue ->rvalue ->object param)

(define-struct (<function> <cart-object>))

(define-method (->object (obj <function>))
  (make-in-context <cart-object>
                   (function->object (->pointer obj))))

(define (mk-function return-type name location fn-kind params variadic?)
  (set! variadic? (boolean->integer variadic?))
  (define params-arr (apply allocate-array ptr (map ->pointer params)))
  (make-in-context <function>
                   (context-new-function (current-context-pointer)
                                         (->pointer location)
                                         fn-kind
                                         (->pointer return-type)
                                         (->pointer (->string name))
                                         (length params)
                                         params-arr
                                         variadic?)))

(define* (function name return-type params
                   #:key (location (%current-location)) variadic? exported? always-inlined?)
  "Defines a function which is optionally exported to surrounding code"
  (when (and exported? always-inlined?)
    (error "A function cannot be both exported and always inlined"))
  (mk-function return-type name location
               (cond [exported?       FUNCTION-EXPORTED]
                     [always-inlined? FUNCTION-ALWAYS-INLINE]
                     [else            FUNCTION-INTERNAL])
               params variadic?))

(define* (imported-function name return-type params #:key (location (%current-location)) variadic?)
                            
  "Defines a function imported from an external library"
  (mk-function return-type name location FUNCTION-IMPORTED params variadic?))

(define (builtin-function name)
  "Retrieves the builtin function with the given name"
  (make-in-context <function>
                   (context-get-builtin-function
                    (current-context-pointer)
                    (->pointer (->string name)))))
                                                  

(export <function> function imported-function builtin-function)

(define-public (get-param fn indx)
  "Gets the 'indx'-th parameter of the function"
  (make-in-context <param>
                   (function-get-param (->pointer fn) indx)))

(define-public (dump-to-dot! fn file)
  "Dumps the function in a graphiz format to the given file"
  (function-dump-to-dot (->pointer fn) (->pointer file)))

(define-struct (<local> <lvalue>))

(define* (local fn type name #:key (location (%current-location)))
  "Creates a new local variable in the function"
  (make-in-context <local>
                   (function-new-local (->pointer fn)
                                       (->pointer location)
                                       (->pointer type)
                                       (->pointer (->string name)))))

(export <local> local)

(define-struct (<block> <cart-object>))

(define-method (->object (obj <block>))
  (make-in-context <cart-object>
                   (block->object (->pointer obj))))
  
(define* (block fn #:optional name)
  "Creates a new block with an optional name in function 'fn'"
  (make-in-context <block>
                   (function-new-block (->pointer fn)
                                       (->pointer (->string name)))))

(export <block> block)

(define* (block-fn blk)
  "Finds the function in which the given block occurs"
  (make-in-context <function>
                   (block-get-function (->pointer blk))))
                   

(export <block> ->object fn block-fn)

(define* (block-eval! blk rvalue #:key (location (%current-location)))
  "Appends an eval statement onto a block"
  (->pointer! blk rvalue location)
  (block-add-eval blk location rvalue))

(export block-eval!)

(define* (block-assign! blk lvalue rvalue #:key (location (%current-location)))
  "Adds an assignment statement onto a block"
  (->pointer! blk lvalue rvalue location)
  (block-add-assignment blk location lvalue rvalue))

(export block-assign!)

(define* (block-comment! blk comment #:key (location (%current-location)))
  "Adds a comment to a block"
  (->pointer! blk location comment)
  (block-add-comment blk location comment))

(export block-comment!)

(define* (block-end-conditional! blk cond on-true on-false
                                 #:key (location (%current-location)))
  "Ends a basic block with a conditional"
  (->pointer! blk cond on-true on-false location)
  (block-end-with-conditional blk location cond on-true on-false))

(export block-end-conditional!)

(define* (block-end-jump! blk target
                          #:key (location (%current-location)))
  "Ends a basic block with a jump instruction"
  (->pointer! blk target location)
  (block-end-with-jump blk location target))

(export block-end-jump!)

(define* (block-end-return! blk
                            #:optional ret-val
                            #:key (location (%current-location)))
  "Ends a basic block with optionally returning a value"
  (->pointer! blk ret-val location)
  (if (null-pointer? ret-val)
      (block-end-with-void-return blk location)
      (block-end-with-return blk location ret-val)))

(export block-end-return!)

;; TODO: Add support for ending with switch statements

(define-method (reference-to (obj <function>) location)
  (->pointer! obj location)
  (function-get-address obj location)) 
