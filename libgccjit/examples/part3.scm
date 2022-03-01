(import
 (shorthand ffi)
 (cart libgccjit bindings)
 (cart libgccjit enums)
 (system foreign))

(define (create-code ctx)
  (let* ([the-type (context-get-type ctx TYPE-INT)]
         [return-type the-type]
         [n (context-new-param ctx NULL the-type (string->pointer "n"))]
         [params (allocate-array ptr n)]
         [func (context-new-function
                ctx NULL
                FUNCTION-EXPORTED
                return-type
                (string->pointer "loop_test")
                1 params 0)]
         ;; Build Locals
         [i (function-new-local
             func NULL
             the-type (string->pointer "i"))]
         [sum (function-new-local
               func NULL
               the-type (string->pointer "sum"))]
         [b-initial (function-new-block
                     func (string->pointer "initial"))]
         [b-loop-cond (function-new-block
                       func (string->pointer "loop-cond"))]
         [b-loop-body (function-new-block
                       func (string->pointer "loop-body"))]
         [b-after-loop (function-new-block
                        func (string->pointer "after-loop"))])
    ;; sum = 0;
    (block-add-assignment
     b-initial NULL
     sum (context-zero ctx the-type))

    ;; i = 0;
    (block-add-assignment
     b-initial NULL
     i (context-zero ctx the-type))

    (block-end-with-jump b-initial NULL b-loop-cond)

    ;; if (i >= n)
    (block-end-with-conditional
     b-loop-cond NULL
     (context-new-comparison
      ctx NULL
      COMPARISON-GE
      (lvalue->rvalue i)
      (param->rvalue n))
     b-after-loop
     b-loop-body)

    ;; sum += i;
    (block-add-assignment-op
     b-loop-body NULL
     sum
     BINARY-OP-PLUS
     (context-new-binary-op
      ctx NULL
      BINARY-OP-MULT the-type
      (lvalue->rvalue i)
      (lvalue->rvalue i)))

    ;; i++
    (block-add-assignment-op
     b-loop-body NULL
     i
     BINARY-OP-PLUS
     (context-one ctx the-type))

    (block-end-with-jump b-loop-body NULL b-loop-cond)

    ;; return sum;
    (block-end-with-return
     b-after-loop
     NULL
     (lvalue->rvalue sum))))

(define (main)
  (define ctx (assert-not-null (context-acquire)))
  (context-set-bool-option ctx BOOL-OPTION-DUMP-GENERATED-CODE 1)
  (context-set-int-option ctx INT-OPTION-OPTIMIZATION-LEVEL 1)
  (create-code ctx)
  (define res (assert-not-null (context-compile ctx)))
  (define loop-test*
    (assert-not-null (result-get-code res (string->pointer "loop_test"))))
  (define loop-test (pointer->procedure int loop-test* (list int)))
  (for-each display (list "loop_test returned: " (loop-test 10)))
  (newline)
  (context-release ctx)
  (result-release res))

(main)
