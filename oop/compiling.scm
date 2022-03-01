(define-module (cart oop compiling)
  #:use-module (oop goops)
  #:use-module (system foreign)
  #:use-module (shorthand ffi)
  #:use-module (shorthand oop)
  #:use-module (shorthand io)
  #:use-module (cart libgccjit enums)
  #:use-module (cart libgccjit bindings)
  #:use-module (cart oop contexts)
  #:use-module (cart oop objects)
  #:duplicates (merge-generics))

(define-struct (<compiled-code> <wrapped-pointer>))

(define* (compile! #:key (context (%current-context)))
  "Just-In-Time compiles the current context into a result"
  (let ((res (pointer-with-finalizer
              (context-compile (->pointer context))
              $result-release)))
    (check-for-compilation-errors)
    res))

(export compile!)

(define-public (get-function-pointer result name)
  "Gets the function pointer compiled with the given name
   WARNING: the pointer is only valid for as long as the result is valid.
            use get-function if you mean to generate an actual function object"
  (set! name (cond [(string? name) name]
                   [(symbol? name) (symbol->string name)]
                   [else           (error "Invalid name" name)]))
  (result-get-code (->pointer result) (->pointer name)))

(define-public (get-function result name return-type arg-types)
  "Returns the function from the compilation result
   with the given name, return type and argument types"
  ;; By wrapping this in a lambda, I'll close over the result object, ensuring it
  ;; doesn't get dropped until this function is dropped
  (define fn #f)
  (lambda args
    (unless fn
      (set! fn
            (pointer->procedure return-type
                                (get-function-pointer result (->string name))
                                arg-types)))
    (apply fn args)))

(define-public (get-global-pointer result name)
  "Gets the global pointer compiled with the given name
   WARNING: the pointer is only valid for as long as the result is valid"
  (set! name (cond [(string? name) name]
                   [(symbol? name) (symbol->string name)]
                   [else           (error "Invalid name" name)]))
  (make-pointer (result-get-global (->pointer result) (->pointer name))))

(define* (compile-to-file! file #:key (context (%current-context)) output-kind)
  "Ahead-Of-Time compiles the context into a file, which is converted into a
   code object depending on the suffix."
  (set! output-kind (cond [output-kind output-kind]
                          [(string-suffix-ci? file ".s")   'assembler]
                          [(string-suffix-ci? file ".o")   'object]
                          [(string-suffix-ci? file ".so")  'dynamic-library]
                          [(string-suffix-ci? file ".dll") 'dynamic-library]
                          [else                            'executable]))
  (set! output-kind (case output-kind
                      [(assembler)       OUTPUT-KIND-ASSEMBLER]
                      [(object)          OUTPUT-KIND-OBJECT-FILE]
                      [(dynamic-library) OUTPUT-KIND-DYNAMIC-LIBRARY]
                      [(executable)      OUTPUT-KIND-EXECUTABLE]
                      [else              (error "Invalid compilation output kind" output-kind)]))
  (context-compile-to-file (->pointer context)
                           output-kind
                           (->pointer file)))
  

(export compile-to-file!)
