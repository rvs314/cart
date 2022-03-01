(import (cart libgccjit bindings)
        (cart libgccjit enums)
        (shorthand ffi)
        (system foreign)
        (rnrs))

(define (create-code ctx)
  (let* [(void-type (context-get-type ctx TYPE-VOID))
         (const-char* (context-get-type ctx TYPE-CONST-CHAR-PTR))
         (param-name (context-new-param ctx NULL const-char* (string->pointer "name")))
         (func (context-new-function
                ctx NULL
                FUNCTION-EXPORTED
                void-type
                (string->pointer "greet")
                1 (allocate-array '* param-name)
                0))
         (param-format (context-new-param
                        ctx NULL
                        const-char* (string->pointer "format")))
         (printf-func (context-new-function
                       ctx NULL
                       FUNCTION-IMPORTED
                       (context-get-type ctx TYPE-INT)
                       (string->pointer "printf")
                       1 (allocate-array '* param-format)
                       1))
         (args (allocate-array '*
                         (context-new-string-literal ctx (string->pointer "hello %s\n"))
                         (param->rvalue param-name)))
         (block (function-new-block func NULL))]
    (block-add-eval block NULL
                    (context-new-call ctx NULL printf-func 2 args))
    (block-end-with-void-return block NULL)))

(define (main)
  (define ctx (assert-not-null (context-acquire)))
  (context-set-int-option ctx INT-OPTION-OPTIMIZATION-LEVEL 3)
  (context-set-bool-option ctx BOOL-OPTION-DUMP-GENERATED-CODE 0)
  (context-set-bool-option ctx BOOL-OPTION-DUMP-INITIAL-GIMPLE 1)
  (create-code ctx)
  (define res (assert-not-null (context-compile ctx)))
  (define greet (assert-not-null (result-get-code res (string->pointer "greet"))))
  (define greet-fn (pointer->procedure void greet (list '*)))
  (greet-fn (string->pointer "world"))

  (context-release ctx)
  (result-release res))
