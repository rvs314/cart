(define-module (cart language module)
  #:use-module (shorthand io))

(define base-module (resolve-module '(cart language base)
                     #:ensure #t))

(define-syntax module-define-all!
  (syntax-rules ()
    [(module-define-all! mod) (begin)]
    [(module-define-all! mod name val rest ...)
     (begin (module-define! mod (quote name) (make-variable val))
            (module-define-all! mod rest ...))]))

(define (ref name)
  (module-ref (current-module) name))

(module-define! base-module
                'def
                (ref 'define))

