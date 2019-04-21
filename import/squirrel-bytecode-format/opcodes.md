# Squirrel Opcodes

Each squirrel instruction is fixed-length, at 64 bits, and looks like this:

    arg1: i32 | op: u8 | arg0: u8 | arg2: u8 | arg3: u8

**TODO Little-endian?**

In the C++ implementation of the bytecode interpreter, it uses `TARGET` as shorthand for the stack position identified by `arg0`.

TODO: Decide whether to use an x86-like SP+0 syntax, or a register-based VM syntax based on r0 (or even x0, as in Erlang). For now, using r0. Kinda makes sense to use r0 and make it clear that registers are windowed, rather than using SP+0, which allows for the stack to be messed around with inside the function, which _isn't_ allowed (afaik) by the Squirrel VM.

The Squirrel opcodes are listed in squirrel/sqopcodes.h

## `_OP_LINE`

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

## `_OP_TAILCALL = 0x05` - perform a tailcall
## `_OP_CALL = 0x06` - perform a normal call 
## `_OP_PREPCALL = 0x07` - prepare a call
## `_OP_PREPCALLK = 0x08` - prepare a callk (??)
## `_OP_GETK = 0x09` - 
## `_OP_MOVE = 0x0A` - move a value from one register to another

    (move r0 r1)    ; move the value in r0 into r1

Encoded as `{ op: 0x0A, arg0: 1, arg1: 0 }`.

Does it actually _move_ the value, or _copy_ it? It depends on the ownership semantics of the underlying SQObject.

## `_OP_NEWSLOT = 0x0B` - store a value in a table, class or instance

Given a table, class or instance on the stack at position arg1, store the value at arg3 into the slot identified by the key at arg2. Optionally copy the value at arg3 to the stack at arg0.

Note: _at_ vs. _in_.

arg1 self, arg2 key, arg3 val, r.arg0 := arg3

    (new-slot r0 r1 r2)     ; r0[r1] := r2
    (new-slot' r0 r1 r2 r3) ; r0[r1] := r2; r3 := r2

...wondering whether the S-expressions should mirror the arg values of the instructions, even if that doesn't particularly make sense.

Decided: no. The arg values of the instructions need to cater for the fact that arg1 is 32-bit, but the others are all 8-bit, and usually refer to registers / stack locations.

This means that the ordering w.r.t. source and destination, particularly w.r.t. arg0, which is 8-bit might be completely arbitrary. That means that it might make more sense to enforce source..dest ordering in the S-expressions.

OTOH, given that TARGET is used a lot, and is Stk[arg0], maybe it makes more sense to have dest..source ordering (cf Intel syntax)...?

Might be worth trying?

For `new-slot'`, that'd be `(new-slot' r0 r1 r2 r3) ; r1[r2] := r3; r0 := r3` ... which isn't terrible.

I'm beginning to think that S-expressions would be better enhanced with named parameters. Something like: `new-slot(self: r0, key: r1, value: r2, target: r3)`, but then that's almost a complete language in itself, which means it needs a custom non-S-expr parser. Meh.

## `_OP_DELETE = 0x0C` - delete a key from a table, class or instance

...or a UserData (??)

Delete, from the object at arg1, the slot with key at arg2, saving the previous value at arg0.

    (delete r0 r1)
    (delete' r0 r1 r2)

...maybe.

## `_OP_SET = 0x0D` - store a value in a table, class or instance, fail if the key's not present

Also some shenanigans to do with the root table. Also not that this and new-slot invoke delegates, which is going to be an interesting discussion. It's part of the runtime semantics, rather than part of the bytecode semantics, though.

## `_OP_GET = 0x0E` - get a value from a table, class or instance.

It's at this point that I decide that this document needs to be broken down by category of instruction, so that the concept of class, table, instance, etc. can be introduced alongside those instructions, and that simple instructions can all be dealt with first.

Also, given this is a discussion, not a reference, it's fine to talk about TARGET, etc., early on, without repeating that discussion in every later section.

## `_OP_EQ = 0x0F` - 
## `_OP_NE = 0x10` -

Equality comparisons. There are other comparison operators later.

## `_OP_ADD = 0x11` - 
## `_OP_SUB = 0x12` - 
## `_OP_MUL = 0x13` - 
## `_OP_DIV = 0x14` - 
## `_OP_MOD = 0x15` - 

Arithmetic operations.

## `_OP_BITW = 0x16` - 

First bitwise operator. Exactly which bitwise operator is encoded as one of the arguments, so you'd probably use different operator names in the S-expression.

    (band r0 r1 r2)     ; r2 := r0 & r1
    (bor r0 r1 r2)      ; r2 := r0 | r1
    (bxor r0 r1 r2)     ; r2 := r0 ^ r1
    (bsl r0 r1 r2)      ; r2 := r0 << r1 
    (bsr r0 r1 r2)      ; r2 := r0 >> r1
    (bsru r0 r1 r2)     ; unsigned shift right

The semantics of the bitwise operators is exactly whatever the C++ compiler gives you, which is implementation-defined (??), so... yeah.

Squirrel doesn't appear to have instructions that can directly encode the shift amount, which is, given that we're using it in IoT, kinda disappointing, in terms of instruction density.

Do we prefer `:=` or `:=` in our pseudo-code?

## `_OP_RETURN = 0x17` - 
## `_OP_LOADNULLS = 0x18` - 
## `_OP_LOADROOT = 0x19` - 
## `_OP_LOADBOOL = 0x1A` - 
## `_OP_DMOVE = 0x1B` - 
## `_OP_JMP = 0x1C` - 
## `//_OP_JNZ = 0x1D` - 
## `_OP_JCMP = 0x1D` - 
## `_OP_JZ = 0x1E` - 
## `_OP_SETOUTER = 0x1F` - 
## `_OP_GETOUTER = 0x20` - 
## `_OP_NEWOBJ = 0x21` - 
## `_OP_APPENDARRAY = 0x22` - 
## `_OP_COMPARITH = 0x23` - 
## `_OP_INC = 0x24` - 
## `_OP_INCL = 0x25` - 
## `_OP_PINC = 0x26` - 
## `_OP_PINCL = 0x27` - 
## `_OP_CMP = 0x28` - 
## `_OP_EXISTS = 0x29` - 
## `_OP_INSTANCEOF = 0x2A` - 

## `_OP_AND = 0x2B` - 
## `_OP_OR = 0x2C` - 
## `_OP_NEG = 0x2D` - 
## `_OP_NOT = 0x2E` - 

Boolean operators.

## `_OP_BWNOT = 0x2F` -

Another bitwise operator.

## `_OP_CLOSURE = 0x30` - 

## `_OP_YIELD = 0x31` - 
## `_OP_RESUME = 0x32` - 

## `_OP_FOREACH = 0x33` - 
## `_OP_POSTFOREACH = 0x34` - 

## `_OP_CLONE = 0x35` - 
## `_OP_TYPEOF = 0x36` - 

## `_OP_PUSHTRAP = 0x37` - 
## `_OP_POPTRAP = 0x38` - 
## `_OP_THROW = 0x39` - 

## `_OP_NEWSLOTA = 0x3A` - 
## `_OP_GETBASE = 0x3B` - 
## `_OP_CLOSE = 0x3C` - 
