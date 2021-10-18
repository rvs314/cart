(use-modules (system foreign)
             (system foreign-library))

(define j0
  (foreign-library-function #f "j0"
                            #:return-type double
                            #:arg-types (list double)))
