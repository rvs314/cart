(define-module (cart oop locations)
  #:use-module (guile)
  #:use-module (oop goops)
  #:use-module (system foreign)
  #:use-module (shorthand ffi)
  #:use-module (shorthand utils)
  #:use-module (shorthand oop)
  #:use-module (cart libgccjit enums)
  #:use-module (cart libgccjit bindings)
  #:use-module (cart oop contexts)
  #:use-module (cart oop objects)
  #:duplicates (merge-generics))

(define-struct (<location> <cart-object>))

(export <location>)

(define-public (location filename line column)
  (make-in-context <location>
                   (context-new-location
                    (current-context-pointer)
                    (string->pointer filename)
                    line column)))

(define* (syntax->location stx #:key line column filename)
  "Extracts the location information from a syntax object."
  (define src (syntax-source stx))
  (and src
       (let ([ln (maybe cdr (assoc 'line src) line)]
             [fn (maybe cdr (assoc 'filename src) filename)]
             [cl (maybe cdr (assoc 'column src) column)])
         (unless (and ln fn cl)
           (warn "Location not fully specified" ln fn cl))
         (and ln fn cl (location fn ln cl)))))

(export syntax->location)

(define-public %current-location (fluid->parameter (make-thread-local-fluid #f)))

(define-syntax-rule (with-location loc body body* ...)
  (parameterize ([%current-location loc])
    body body* ...))

(define-syntax-rule (this-location)
  (syntax->location #'here #:filename (current-filename)))

(export %current-location with-location this-location)
