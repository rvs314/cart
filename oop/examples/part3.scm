(define-module (cart oop examples part3)
  #:use-module (oop goops)
  #:use-module (shorthand ffi)
  #:use-module (shorthand io)
  #:use-module (shorthand syntax)
  #:use-module (cart oop contexts)
  #:use-module (cart oop types)
  #:use-module (cart oop functions)
  #:use-module (cart oop rvalues)
  #:use-module (cart oop compiling)
  #:use-module (cart oop objects)
  #:use-module ((system foreign) #:prefix ffi:)
  #:duplicates (merge-generics))

(define (build-test)
  (with-new-context
   (define-all
     n          (param (int) "n")
     test       (function "loop_test" (int) (list n) #:exported? #t)
     start      (block test)
     cnd        (block test)
     loop       (block test)
     after-loop (block test)
     sum        (local test (int) "sum")
     i          (local test (int) "i"))

   (block-assign!   start sum (number-literal (int) 0))
   (block-assign!   start i   (number-literal (int) 0))
   (block-end-jump! start cnd)

   (block-end-conditional! cnd (less-than i n) loop after-loop)

   (block-assign!   loop sum (addition sum (multiplication i i (int)) (int)))
   (block-assign!   loop i   (addition i (number-literal (int) 1) (int)))
   (block-end-jump! loop cnd)

   (block-end-return! after-loop sum)

   (define res (compile!))

   (get-function res 'loop_test ffi:int (list ffi:int))))

(define (main)
  (define s (build-test))         
  (s 10))

(puts (main))
