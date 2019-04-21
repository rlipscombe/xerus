---
layout: page
---

# Squirrel Opcodes

Each squirrel instruction is fixed-length, at 64 bits, and looks like this:

    arg1: i32 | op: u8 | arg0: u8 | arg2: u8 | arg3: u8

Comparison with Lua:

Lua has 32-bit instructions, and refers to the arguments as A, B, C, and D.
This makes it easier to refer to the registers, because you can talk about rA
as the register that operand A refers to, etc..

Whereas here, we've got arg0 and r0, which is a bit confusing.
We can't use `r[0]`, because it looks like an array access.

Other ideas?

- [loads](loads)
- [arith](arith)
- [bitwise](bitwise)
- [comparisons](comparisons)
- [jumps](jumps)
- [structs](structs)
- [calls](calls)

## `_OP_LINE = 0x00`
## `_OP_GETK = 0x09` -
## `_OP_MOVE = 0x0A` - move a value from one register to another

    (move r0 r1)    ; move the value in r0 into r1

Encoded as `{ op: 0x0A, arg0: 1, arg1: 0 }`.

Does it actually _move_ the value, or _copy_ it? It depends on the ownership semantics of the underlying SQObject.

## `_OP_LOADNULLS = 0x18` -
## `_OP_LOADROOT = 0x19` -
## `_OP_LOADBOOL = 0x1A` -
## `_OP_DMOVE = 0x1B` -
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
