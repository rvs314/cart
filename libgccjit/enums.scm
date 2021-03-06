(define-module (cart libgccjit enums) #:use-module (guile))

(define-public TYPE-VOID 0)
(define-public TYPE-VOID-PTR 1)
(define-public TYPE-BOOL 2)
(define-public TYPE-CHAR 3)
(define-public TYPE-SIGNED-CHAR 4)
(define-public TYPE-UNSIGNED-CHAR 5)
(define-public TYPE-SHORT 6)
(define-public TYPE-UNSIGNED-SHORT 7)
(define-public TYPE-INT 8)
(define-public TYPE-UNSIGNED-INT 9)
(define-public TYPE-LONG 10)
(define-public TYPE-UNSIGNED-LONG 11)
(define-public TYPE-LONG-LONG 12)
(define-public TYPE-UNSIGNED-LONG-LONG 13)
(define-public TYPE-FLOAT 14)
(define-public TYPE-DOUBLE 15)
(define-public TYPE-LONG-DOUBLE 16)
(define-public TYPE-CONST-CHAR-PTR 17)
(define-public TYPE-SIZE-T 18)
(define-public TYPE-FILE-PTR 19)
(define-public TYPE-COMPLEX-FLOAT 20)
(define-public TYPE-COMPLEX-DOUBLE 21)
(define-public TYPE-COMPLEX-LONG-DOUBLE 22)
(define-public FUNCTION-EXPORTED 0)
(define-public FUNCTION-INTERNAL 1)
(define-public FUNCTION-IMPORTED 2)
(define-public FUNCTION-ALWAYS-INLINE 3)
(define-public STR-OPTION-PROGNAME 0)
(define-public BOOL-OPTION-DEBUGINFO 0)
(define-public BOOL-OPTION-DUMP-INITIAL-TREE 1)
(define-public BOOL-OPTION-DUMP-INITIAL-GIMPLE 2)
(define-public BOOL-OPTION-DUMP-GENERATED-CODE 3)
(define-public BOOL-OPTION-DUMP-SUMMARY 4)
(define-public BOOL-OPTION-DUMP-EVERYTHING 5)
(define-public BOOL-OPTION-SELFCHECK-GC 6)
(define-public BOOL-OPTION-KEEP-INTERMEDIATES 7)
(define-public INT-OPTION-OPTIMIZATION-LEVEL 0)
(define-public UNARY-OP-MINUS 0)
(define-public UNARY-OP-BITWISE-NEGATE 1)
(define-public UNARY-OP-LOGICAL-NEGATE 2)
(define-public UNARY-OP-ABS 3)
(define-public BINARY-OP-PLUS 0)
(define-public BINARY-OP-MINUS 1)
(define-public BINARY-OP-MULT 2)
(define-public BINARY-OP-DIVIDE 3)
(define-public BINARY-OP-MODULO 4)
(define-public BINARY-OP-BITWISE-AND 5)
(define-public BINARY-OP-BITWISE-XOR 6)
(define-public BINARY-OP-BITWISE-OR 7)
(define-public BINARY-OP-LOGICAL-AND 8)
(define-public BINARY-OP-LOGICAL-OR 9)
(define-public BINARY-OP-LSHIFT 10)
(define-public BINARY-OP-RSHIFT 11)
(define-public COMPARISON-EQ 0)
(define-public COMPARISON-NE 1)
(define-public COMPARISON-LT 2)
(define-public COMPARISON-LE 3)
(define-public COMPARISON-GT 4)
(define-public COMPARISON-GE 5)
(define-public GLOBAL-EXPORTED 0)
(define-public GLOBAL-INTERNAL 1)
(define-public GLOBAL-IMPORTED 2)
(define-public OUTPUT-KIND-ASSEMBLER 0)
(define-public OUTPUT-KIND-OBJECT-FILE 1)
(define-public OUTPUT-KIND-DYNAMIC-LIBRARY 2)
(define-public OUTPUT-KIND-EXECUTABLE 3)
