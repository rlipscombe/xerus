---
layout: page
---

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

## `_OP_BWNOT = 0x2F` -

Another bitwise operator.
