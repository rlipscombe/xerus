---
layout: page
---
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
