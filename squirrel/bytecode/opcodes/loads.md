---
layout: page
---

## `_OP_LOAD = 0x01` - load a string literal

String literals are interned and stored in the "literals" table in the file record (??). They are identified by their index.

`_OP_LOAD` loads the string literal identified by `arg1` into `TARGET` (the stack position identified by `arg0`).

`(load-string "Hello World!" r2)` would result in "Hello World!" being stored as a literal (e.g. as literal 6) and then this would be lowered to `(load-literal 6 2)` and would be encoded as `{ op: 0x01, arg0: 2, arg1: 6 }`.

## `_OP_LOADINT = 0x02` - load an integer

`_OP_LOADINT` loads the 32-bit integer constant stored in `arg1` into `TARGET` (the stack position identified by `arg0`).

`(load-int 42 r1)` would result in the integer 42 being stored in the `r1` register, and would be encoded as `{ op: 0x02, arg0: 1, arg1: 42 }`

## `_OP_LOADFLOAT = 0x03` - load a single-precision floating point value

cf LOADINT

## `_OP_DLOAD = 0x04` - load a pair of string literals

TODO: Obviously this is an optimisation. Question is: what is it used for?

`_OP_DLOAD` loads two string literals at once.

The literal identified by `arg1` is stored into `TARGET` (the register/stack position identified by `arg0`).

The literal identified by `arg3` is stored into the register identified by `arg2`.

Contrived example:

    (load-string "Hello " r2)   ; literal #1
    (load-string "World!" r3)  ; literal #2

...might be encoded as `{ op: 0x04, arg0: 2, arg1: 1, arg2: 3, arg3: 2 }`
