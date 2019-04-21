---
layout: page
---

# Arithmetic operations

## `_OP_ADD = 0x11` - add two registers

    local x = 1 + 2;

LHS is in arg2, RHS is in arg1, result is stored to arg0.

The squirrel compiler doesn't do constant folding, so this is encoded as two loads and an add:

    ; arg1      | op | a0 | a2 | a3
    01 00 00 00 | 02 | 02 | 00 | 00     ; (load-int 1 r2)
    02 00 00 00 | 02 | 03 | 00 | 00     ; (load-int 2 r3)
    03 00 00 00 | 11 | 02 | 02 | 00     ; (add r2 r3 r2)  ;; r2 := r2 + r3

Using s-expressions isn't massively clear here, because you need to remember the order of operands. While writing this page I confused myself. This might be better expressed as `add(lhs: r2, rhs: r3, dest: r2)`.

Or maybe we don't bother using s-expressions, and just use `r2 := r2 + r3`, for example.

Note that the compiler hasn't used another register for the destination.

Let's try something a bit more complicated:

    local a = 1 + 2;
    local b = 3 + 4;
    local c = a + b;

    ; arg1      | op | a0 | a2 | a3
    01 00 00 00 | 02 | 02 | 00 | 00     ; (load-int 1 r2)   ;; r2 := 1
    02 00 00 00 | 02 | 03 | 00 | 00     ; (load-int 2 r3)   ;; r3 := 2
    03 00 00 00 | 11 | 02 | 02 | 00     ; (add r2 r3 r2)    ;; r2 := r2 + r3 ;; r2 used for 'a'
    03 00 00 00 | 02 | 03 | 00 | 00     ; (load-int 3 r3)   ;; r3 := 3
    04 00 00 00 | 02 | 04 | 00 | 00     ; (load-int 4 r4)   ;; r4 := 4
    04 00 00 00 | 11 | 03 | 03 | 00     ; (add r3 r4 r3)    ;; r3 := r3 + r4 ;; r3 used for 'b'
    03 00 00 00 | 11 | 04 | 02 | 00     ; (add r2 r3 r4)    ;; r4 := r2 + r3 ;; r4 used for 'c'

The compiler seems to keep a high-water-mark when allocating registers.

## `_OP_SUB = 0x12` -
## `_OP_MUL = 0x13` -
## `_OP_DIV = 0x14` -
## `_OP_MOD = 0x15` -
## `_OP_NEG = 0x2D` -
