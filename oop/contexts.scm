(define-module (cart oop contexts)
  #:use-module (oop goops)
  #:use-module (ice-9 exceptions)
  #:use-module (system foreign)
  #:use-module (shorthand oop)
  #:use-module (shorthand ffi)
  #:use-module (cart libgccjit bindings)
  #:use-module (cart libgccjit enums)
  #:duplicates (merge-generics))

(define-struct (<context> <wrapped-pointer>))

(export <context>)

(define-public (make-context)
  (make <context>
    #:pointer (pointer-with-finalizer (context-acquire)
                                      $context-release)))

;; The current context used for the compiler
(define-public %current-context (fluid->parameter (make-thread-local-fluid)))

;; The current context pointer
(define-public (current-context-pointer)
  (let [[cc (%current-context)]]
    (unless cc
        (error "Attempting to access context pointer while not in a compilation context."))
    (pointer cc)))

(define-syntax-rule (with-new-context body body* ...)
  (parameterize [[%current-context (make-context)]]
    body body* ...))

(define* (new-context! #:optional new-context)
  "Sets the current compilation context"
  (%current-context (or new-context (make-context))))

(export with-new-context new-context!)

;; TODO: Implement child contexts

(export with-new-context)

(define-exception-type &cart-error &non-continuable
  make-cart-error cart-error?
  (error-message cart-error-message))

(define-public (check-for-compilation-errors)
  "Checks the current context object to see if there are any errors"
  (define last-error (context-get-last-error (current-context-pointer)))
  (if (null-pointer? last-error)
      #f
      (raise-exception
        (make-cart-error (string-copy (pointer->string last-error))))))

(export &cart-error cart-error-message)

(define* (dump-to-file! filename #:optional fake-locations)
  "To help with debugging: dump a C-like representation to the given path,
describing what’s been set up on the context. If 'fake-locations' is provided,
then the generated code is marked as the location of the generated code."
  (context-dump-to-file (current-context-pointer)
                        (string->pointer filename)
                        (boolean->integer fake-locations))
  (check-for-compilation-errors))

(export dump-to-file!)

;; TODO: Implement set-logfile

(define-public (dump-reproducer filename)
  "Dumps a C program which replays the libgccjit calls executed so far."
  (context-dump-reproducer-to-file (current-context-pointer)
                                   (string->pointer filename))
  (check-for-compilation-errors))

;; TODO: Implement enable-dump

(define-public (set-error-prefix! name)
  "Sets the name used as an error prefix in error messages"
  (context-set-str-option (current-context-pointer)
                          STR-OPTION-PROGNAME
                          (string->pointer name)))

(define* (set-debuginfo! #:optional (val #t))
  "Enable or disable debugging information"
  (context-set-bool-option (current-context-pointer)
                           BOOL-OPTION-DEBUGINFO
                           (boolean->integer val)))

(export set-debuginfo!)

(define-public (set-compilation-dump! . val)
  "Changes what is to be dumped to stderr during compilation.
The following are valid compilation options:
- tree :: dumps the tree representation of the compiled code
- gimple :: dumps the C-like gimple representation of the compiled code
- code :: dumps the assembly representation of the compiled code
- intermediates :: dumps the intermediate optimization passes
- everything :: dumps everything
- summary :: dump a summary of the compilation"
  (define options `((tree . ,BOOL-OPTION-DUMP-INITIAL-TREE)
                    (gimple . ,BOOL-OPTION-DUMP-INITIAL-GIMPLE)
                    (code . ,BOOL-OPTION-DUMP-GENERATED-CODE)
                    (everything . ,BOOL-OPTION-DUMP-EVERYTHING)
                    (intermediates . ,BOOL-OPTION-KEEP-INTERMEDIATES)
                    (summary . ,BOOL-OPTION-DUMP-SUMMARY)))
  (for-each
   (lambda (op)
     (context-set-bool-option (current-context-pointer)
                              (cdr op)
                              (boolean->integer (member (car op) val))))
   options))

(define-public (set-allow-unreachable-blocks! val)
  "Enables or disables the error corresponding unreachable blocks"
  (context-set-bool-allow-unreachable-blocks
   (current-context-pointer)
   (boolean->integer val)))

(define-public (set-use-external-driver! val)
  "Whether or not to use an external driver instead of the internal one"
  (context-set-bool-use-external-driver
   (current-context-pointer)
   (boolean->integer val)))

(define-public (set-optimization-level! level)
  "Sets the current optimization level (0-3), corresponding to GCC's -O0 to -O3 level"
  (context-set-int-option
   (current-context-pointer)
   INT-OPTION-OPTIMIZATION-LEVEL
   level))

(define-public (add-command-line-option! option)
  "Adds a GCC commandline option to the compiler"
  (context-add-command-line-option
   (current-context-pointer)
   (string->pointer option)))

(define-public (add-driver-option! option)
  "Adds a GCC commandline option to the driver"
  (context-add-driver-option
   (current-context-pointer)
   (string->pointer option)))

