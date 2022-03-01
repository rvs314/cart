(import (cart libgccjit bindings)
        (cart libgccjit enums)
        (shorthand ffi)
        (system foreign))

(define (create-code ctx)
  (let* [(int-type (context-get-type ctx TYPE-INT))
         (param-i  (context-new-param ctx NULL int-type (string->pointer "i")))
         (func     (context-new-function
                    ctx NULL
                    FUNCTION-EXPORTED int-type
                    (string->pointer "square")
                    1 (allocate-array '* param-i)
                    0))
         (block    (function-new-block func NULL))
         (expr     (context-new-binary-op
                    ctx NULL
                    BINARY-OP-MULT int-type
                    (param->rvalue param-i)
                    (param->rvalue param-i)))]
    (block-end-with-return block NULL expr)))

(define (main)
  (define ctx (assert-not-null (context-acquire)))
  (context-set-bool-option ctx BOOL-OPTION-DUMP-GENERATED-CODE 0)
  (create-code ctx)
  (define res (assert-not-null (context-compile ctx)))
  (context-release ctx)
  (define square-fn* (result-get-code res (string->pointer "square")))
  (define square-fn (pointer->procedure int square-fn* (list int)))
  (for-each display (list "result: " (square-fn 5)))
  (newline)
  (result-release res))
