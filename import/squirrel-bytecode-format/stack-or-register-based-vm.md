There are two main types of bytecode interpreters (VMs) in common use: stack-based and register-based. .NET and JVM are examples of stack-based VMs. Lua and Squirrel are examples of register-based VMs.

For example, in .NET, you might see:

    ldc.i4 123      // push 123 onto the stack
    ldc.i4 987      // push 987 onto the stack
    add             // pop 2 values, add them, push the result

`ldc.i4` is "load constant, integer, 4 bytes"

Squirrel doesn't have a human-readable "assembly" format, so I'm going to invent one, and have it look a lot like LISP S-expressions. The equivalent to the above might look something like the following:

    (load-int 123 r0)   ; put 123 into r0
    (load-int 987 r1)   ; put 987 into r1   
    (add r0 r1 r2)      ; add r0 and r1, put the result in r2

In Lua and Squirrel, the registers (r0, etc.) are relative to the current "activation context". In another language, we might call this the "stack frame".

If you look at the official implementation of the Squirrel VM, you'll see that it uses the term "stack" to refer to the current activation context.

In fact, I'm wondering whether using r0-syntax for this is justified. It's almost like Squirrel compiles down to some sort of x86-like, in terms of its stack usage. Never mind; it's just a case of changing r0 to ... something else, such as s0.

Aside: WebAssembly is a "structured stack machine", per https://github.com/WebAssembly/design/blob/master/Rationale.md#why-a-stack-machine.

I don't know what that _is_, but the text also mentions some other options:

> Why not an AST, or a register- or SSA-based bytecode?

Obviously, we know what a register-based machine is. I don't know what an SSA-based bytecode is, but I suspect it's related in concept to the SSA changes made to the Erlang compiler in OTP-22 (??).

An AST is an AST, which presumably means just storing the AST in the saved "bytecode" file.

Where does LLVM IR or bitcode sit in this family?