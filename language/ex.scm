;; Example of something written using the cart language 

(cart
 (foo bar)

 (define (sum (int x y)) int
   (return (+ x y)))
 
 (define (main (int argc) ((* (* char)) argv)) int
   (puts "The sum of " x " and " y " is " (sum x y))
   (return 1))

 (define-syntax (puts stx)
   (syntax-rules ()
     [(puts x ...)
      (begin (begin (print (cast string x))
                    ...)
             (print #\newline))]))

 (compile-to "test" main))

;; Defines a module called (foo bar)
;; Has a series of imports that define cart primitives

#|
Module Then Becomes:

(define-module (foo bar)
   ;; In actual guile this would implicitly use (guile),
   ;; but we don't want that to happen
   #:use-module (cart base))

(define sum
 (let* ((x  (param (int) "x"))
        (y  (param (int) "y"))
        (fn (function "sum" (int) (list x y) #:exported? #t)))
  (paramaterize ((%current-function fn))
   (let ()
    (let ((b1 (block (%current-function))))
     (block-return! b1 (addition x y (int))))))))
|#
