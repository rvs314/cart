(define-module (cart oop types)
  #:use-module (rnrs)
  #:use-module (srfi srfi-1)
  #:use-module (oop goops)
  #:use-module (shorthand ffi)
  #:use-module (shorthand oop)
  #:use-module (shorthand syntax)
  #:use-module (cart libgccjit enums)
  #:use-module (cart libgccjit bindings)
  #:use-module (cart oop contexts)
  #:use-module (cart oop objects)
  #:use-module (cart oop locations)
  #:duplicates (merge-generics))

(define-struct (<type> <cart-object>))

(export <type>)

(define-method (->object (obj <type>))
  (make-in-context <cart-object>
                   (type->object (->pointer obj))))

(define-method (->type (obj <type>))
  obj)

(define-syntax-rule (->type! obj ...)
  (begin (set! obj (->type obj))
         ...))

(define (builtin jit-type)
  (lambda ()
    (make-in-context <type>
                     (context-get-type (current-context-pointer)
                                       jit-type))))

(define-all public
  unsigned-int        (builtin TYPE-UNSIGNED-INT)
  void                (builtin TYPE-VOID)
  void-pointer        (builtin TYPE-VOID-PTR)
  bool                (builtin TYPE-BOOL)
  signed-char         (builtin TYPE-SIGNED-CHAR)
  complex-float       (builtin TYPE-COMPLEX-FLOAT)
  char                (builtin TYPE-CHAR)
  unsigned-short      (builtin TYPE-UNSIGNED-SHORT)
  short               (builtin TYPE-SHORT)
  long-double         (builtin TYPE-LONG-DOUBLE)
  unsigned-char       (builtin TYPE-UNSIGNED-CHAR)
  file-pointer        (builtin TYPE-FILE-PTR)
  unsigned-long       (builtin TYPE-UNSIGNED-LONG)
  unsigned-long-long  (builtin TYPE-UNSIGNED-LONG-LONG)
  float               (builtin TYPE-FLOAT)
  double              (builtin TYPE-DOUBLE)
  int                 (builtin TYPE-INT)
  const-char-pointer  (builtin TYPE-CONST-CHAR-PTR)
  complex-double      (builtin TYPE-COMPLEX-DOUBLE)
  complex-long-double (builtin TYPE-COMPLEX-LONG-DOUBLE)
  size-t              (builtin TYPE-SIZE-T)
  long                (builtin TYPE-LONG)
  long-long           (builtin TYPE-LONG-LONG))

(define (type ptr)
  (make-in-context <type> ptr))

(define-public (int-type size signed?)
  (type
   (context-get-int-type
    (current-context-pointer)
    size
    (boolean->integer signed?))))

(define-public (pointer-to typ)
  (->type! typ)
  (type (type-get-pointer (->pointer typ))))
  
(define-public (const typ)
  (->type! typ)
  (type (type-get-const (->pointer typ))))

(define-public (volatile typ)
  (->type! typ)
  (type (type-get-volatile (->pointer typ))))

(define* (array-of typ size #:key (location (%current-location)))
  (->type! typ)
  (type (context-new-array-type
         (current-context-pointer)
         (->pointer location)
         (->pointer typ)
         size)))

(export array-of)

(define-public (aligned-to typ alignment)
  (->type! typ)
  (type (type-get-aligned (->pointer typ) alignment)))

(define-public (vector-of typ units)
  (->type! typ)
  (type (type-get-vector (->pointer typ) units)))

(define-struct (<field> <cart-object>))

(define-method (->object (obj <field>))
  (make-in-context <object>
                   (field->object obj)))

(define* (field type name #:key (location (%current-location)))
  (->type! type)
  (make-in-context <field>
                   (context-new-field (current-context-pointer)
                                      (->pointer location)
                                      (->pointer type)
                                      (->pointer name))))

(define-struct (<bitfield> <field>))

(define* (bitfield type name width #:key (location (%current-location)))
  (->type! type)
  (make-in-context <bitfield>
             (context-new-bitfield (current-context-pointer)
                                   (->pointer location)
                                   (->pointer type)
                                   (->pointer name)
                                   width)))

(export ->object
        <field> field
        <bitfield> bitfield)

(define-struct (<struct> <type>))

(define-method (->type (obj <struct>))
  (make-in-context <type>
                   (struct->type (->pointer obj))))

(define* (struct name #:key fields (location (%current-location)))
  (->pointer! name location)
  (make-in-context <struct>
                   (if fields
                       (let-values ([(fs sz) (apply allocate-array ptr (map ->pointer fields))])
                         (context-new-struct-type
                          (current-context-pointer)
                          location
                          name
                          sz
                          fs))
                       (context-new-opaque-struct
                        (current-context-pointer)
                        location
                        name))))

(define* (set-fields! st fields #:key (location (%current-location)))
  (define-values (fs sz) (apply allocate-array ptr (map ->pointer fields)))
  (->pointer! location st)
  (struct-set-fields st
                     location
                     sz
                     fs))

(define* (union name fields #:key (location (%current-location)))
  (define-values (fs sz) (apply allocate-array ptr (map ->pointer fields)))
  (->pointer! name location)
  (make-in-context <type>
                   (context-new-union-type
                    (current-context-pointer)
                    location
                    name
                    sz
                    fs)))

(export struct set-fields! union)

(define* (function-pointer ret-type param-types #:key is-variadic? (location (%current-location)))
  (define-values (arr len) (apply allocate-array ptr (map ->pointer param-types)))
  (type (context-new-function-ptr-type (current-context-pointer)
                            (->pointer location)
                            (->pointer ret-type)
                            len
                            arr
                            (boolean->integer is-variadic?))))

(export function-pointer)
