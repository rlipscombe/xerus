---
layout: page
---

**TODO Little-endian?**

In the C++ implementation of the bytecode interpreter, it uses `TARGET` as shorthand for the stack position identified by `arg0`.

TODO: Decide whether to use an x86-like SP+0 syntax, or a register-based VM syntax based on r0 (or even x0, as in Erlang). For now, using r0. Kinda makes sense to use r0 and make it clear that registers are windowed, rather than using SP+0, which allows for the stack to be messed around with inside the function, which _isn't_ allowed (afaik) by the Squirrel VM.

The Squirrel opcodes are listed in squirrel/sqopcodes.h
