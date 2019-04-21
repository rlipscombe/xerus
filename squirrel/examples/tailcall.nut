// Generate a tailcall instruction
function f(n) {
    if (n == 0) {
        return;
    }

    return f(n-1);
}
