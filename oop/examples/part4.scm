(define-module (cart oop examples part4)
  #:use-module (oop goops)
  #:use-module (shorthand ffi)
  #:use-module (shorthand io)
  #:use-module (shorthand utils)
  #:use-module (shorthand strings)
  #:use-module (shorthand arrows)
  #:use-module (shorthand lists)
  #:use-module (shorthand syntax)
  #:use-module (cart oop contexts)
  #:use-module (cart oop types)
  #:use-module (cart oop functions)
  #:use-module (cart oop rvalues)
  #:use-module (cart oop lvalues)
  #:use-module (cart oop compiling)
  #:use-module (cart oop objects)
  #:use-module (cart oop locations)
  #:use-module ((system foreign) #:prefix ffi:)
  #:duplicates (merge-generics))

(define STACK-SIZE 16)

(define (compile-code name body)
  (with-new-context
   (set-optimization-level! 0)
   (set-debuginfo! #t)

   (with-location
    (syntax->location name)

    (define-all
      input-param (param (int) "input")
      fn (function (syntax->datum name)
                   (int)
                   (list input-param)
                   #:exported? #t)
      stack (local fn (array-of (int) STACK-SIZE) "stack")
      idx   (local fn (int) "idx")
      x     (local fn (int) "x")
      y     (local fn (int) "y")
      start (block fn "start")
      blocks (map-index (lambda (i op)
                          (define b (block fn (format #f "operation_~a" i)))
                          (block-comment! b (->string (syntax->datum op)))
                          b)
                        body))

    (define* (block-push! blk obj #:key (location (%current-location)))
      (with-location
       location
       (block-assign! blk (array-access stack idx) obj)
       (block-assign! blk idx (addition idx (number-literal (int) 1) (int)))))

    (define* (block-pop! blk pos #:key (location (%current-location)))
      (with-location
       location
       (block-assign! blk idx (subtraction idx (number-literal (int) 1) (int)))
       (block-assign! blk pos (array-access stack idx))))

    ;; Initialize the stack
    (block-assign! start idx (number-literal (int) 0))
    (block-push! start input-param)
    (block-end-jump! start (car blocks))

    ;; Initialize the blocks
    (for-each-index
     (lambda (i op)
       (with-location
        (syntax->location (car op))
        (define ins (map syntax->datum op))
        (define blk (list-ref blocks i))
        (define next-block (and (< (1+ i) (length blocks))
                                (list-ref blocks (1+ i))))
                               
        (define (binex op)
          (lambda (x y) (op x y (int))))
        (define (binop op)
          (block-pop! blk x)
          (block-pop! blk y)
          (block-push! blk (op y x)))
        (case (car ins)
          [(dup) (begin (block-pop! blk x)
                        (block-push! blk x)
                        (block-push! blk x))]
          [(rot) (begin (block-pop! blk x)
                        (block-pop! blk y)
                        (block-push! blk x)
                        (block-push! blk y))]
          [(binary-add) (binop (binex addition))]
          [(binary-subtract) (binop (binex subtraction))]
          [(binary-multiply) (binop (binex multiplication))]
          [(binary-compare-<) (binop (lambda (x y)
                                       (cast (less-than x y) (int))))]
          [(recur) (begin (block-pop! blk x)
                          (block-push! blk
                                       (function-call fn (list x))))]
          [(return) (begin (block-pop! blk x)
                           (block-end-return! blk x))]
          [(push-const) (block-push! blk (number-literal (int) (cadr ins)))]
          [(jump-abs-if-true) (begin (block-pop! blk x)
                                     (block-end-conditional! blk
                                                             (equal-to x (number-literal (int) 0))
                                                             next-block
                                                             (list-ref blocks (cadr ins))))])
        (unless (member (car ins) '(jump-abs-if-true return))
          (block-end-jump! blk next-block))))
     body)

    (define-all
      argc (param (int) 'argc)
      argv (param (pointer-to (const-char-pointer)) 'argv)
      main (function 'main (int) (list argc argv) #:exported? #t)
      main-block (block main)
      atoi (imported-function 'atoi (int) (list (param (const-char-pointer) 'nptr)))
      printf (imported-function 'printf (int) (list (param (const-char-pointer) 'fmt))
                                #:variadic? #t)
      in   (local main (int) 'in))

    (block-assign! main-block
                   in (function-call atoi (list (array-access argv (number-literal (int) 1)))))
    (block-assign! main-block
                   in (function-call fn (list in)))
    (block-eval! main-block
                 (function-call printf (list (string-literal "result: %d\n") in)))
    (block-end-return! main-block
                       (number-literal (int) 0)))

   (dump-reproducer "reproduce.c")
   (compile-to-file! (->string (syntax->datum name)))))

   ;; (define comp-res (compile!))
   ;; (get-function comp-res (syntax->datum name) ffi:int (list ffi:int))))

(define-syntax toy-code
  (syntax-rules ()
    [(toy-code name body ...)
     (define name (compile-code #'name (list #'body ...)))])) 

(toy-code factorial
          (dup)
          (push-const 2)
          (binary-compare-<)
          (jump-abs-if-true 9)
          (dup)
          (push-const 1)
          (binary-subtract)
          (recur)
          (binary-multiply)
          (return))

;; (puts (factorial 8))
