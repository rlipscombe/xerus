# `.cnut` file format

Squirrel source code is saved in `.nut` files. These are saved as squirrel bytecode (compiled nut) in `.cnut` files.

Given a completely empty squirrel source file, `blank.nut`, you can compile it with:

    $ sq -c -o blank.cnut blank.nut

...and if you dump it using `xxd`, you get the following:

    $ xxd -g1 blank.cnut
    00000000: fa fa 52 49 51 53 01 00 00 00 08 00 00 00 04 00  ..RIQS..........
    00000010: 00 00 54 52 41 50 10 00 00 08 09 00 00 00 00 00  ..TRAP..........
    00000020: 00 00 62 6c 61 6e 6b 2e 6e 75 74 10 00 00 08 04  ..blank.nut.....
    00000030: 00 00 00 00 00 00 00 6d 61 69 6e 54 52 41 50 00  .......mainTRAP.
    00000040: 00 00 00 00 00 00 00 02 00 00 00 00 00 00 00 00  ................
    00000050: 00 00 00 00 00 00 00 02 00 00 00 00 00 00 00 01  ................
    00000060: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01  ................
    00000070: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 54  ...............T
    00000080: 52 41 50 54 52 41 50 10 00 00 08 04 00 00 00 00  RAPTRAP.........
    00000090: 00 00 00 74 68 69 73 10 00 00 08 05 00 00 00 00  ...this.........
    000000a0: 00 00 00 76 61 72 67 76 54 52 41 50 54 52 41 50  ...vargvTRAPTRAP
    000000b0: 10 00 00 08 05 00 00 00 00 00 00 00 76 61 72 67  ............varg
    000000c0: 76 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00  v...............
    000000d0: 00 00 00 00 00 00 00 00 00 10 00 00 08 04 00 00  ................
    000000e0: 00 00 00 00 00 74 68 69 73 00 00 00 00 00 00 00  .....this.......
    000000f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    00000100: 00 54 52 41 50 01 00 00 00 00 00 00 00 00 00 00  .TRAP...........
    00000110: 00 00 00 00 00 54 52 41 50 54 52 41 50 00 00 00  .....TRAPTRAP...
    00000120: 00 17 ff 00 00 54 52 41 50 02 00 00 00 00 00 00  .....TRAP.......
    00000130: 00 00 01 00 00 00 00 00 00 00 4c 49 41 54        ..........LIAT

The `.cnut` file begins with a bytecode stream tag:

    fa fa - SQ_BYTECODE_STREAM_TAG

This is followed by a serialized closure object:

    52 49 51 53 - SQ_CLOSURESTREAM_HEAD - 'RIQS' - 'SQIR' backwards, because little-endian.
    01 00 00 00 - sizeof(SQChar)
    08 00 00 00 - sizeof(SQInteger) - 64-bit integers
    04 00 00 00 - sizeof(SQFloat) - 32-bit (single-precision) floats
    [Function Proto]
    LIAT

Every squirrel program has an implicit `main` function, and all of the other functions are nested within this.

## Function Proto

A function proto is a sequence of parts, each prefixed with 'TRAP' - 'PART' backwards.

The first part contains the source file name and the function name:

    54 52 41 50 - TRAP (PART backwards)

    10 00 00 08 - type = OT_STRING
    09 00 00 00 00 00 00 00 - length = 9
    62 6c 61 6e 6b 2e 6e 75 74 - 'blank.nut' (no NUL)

    10 00 00 08 - type = OT_STRING
    04 00 00 00 00 00 00 00 - length = 4
    6d 61 69 6e - 'main'

The next part denotes the counts of items in the next parts:

    54 52 41 50 - TRAP (PART backwards)
    00 00 00 00 00 00 00 00 - nliterals
    02 00 00 00 00 00 00 00 - nparameters
    00 00 00 00 00 00 00 00 - noutervalues
    02 00 00 00 00 00 00 00 - nlocalvarinfos
    01 00 00 00 00 00 00 00 - nlineinfos
    00 00 00 00 00 00 00 00 - ndefaultparams
    01 00 00 00 00 00 00 00 - ninstructions
    00 00 00 00 00 00 00 00 - nfunctions

Then there are parts for the literals, parameters, etc.

    [Literals; there are none]
    [Parameters; there are 2...]
    10 00 00 08 - OT_STRING
    04 00 00 00 00 00 00 00 - len = 4
    74 68 69 73 - 'this'

    10 00 00 08 - OT_STRING
    05 00 00 00 00 00 00 00 - len = 5
    76 61 72 67 76 - 'vargv'

    [Outers; there are none]
    [Local Var Infos; there are 2]

Local var infos:

    - name, pos, start_op, end_op -- don't know what they're used for.

    [Line Infos; there is 1]

    - line, op -- this maps a particular op offset to the original line of source.

    [Default Params; there are none]
    [Instructions; there is 1]

    00000000 17 ff 00 00 - {arg1: 0x00000000, op: 0x17, arg0: 0xff, arg2: 0x00, arg3: 0x00}

This is `_OP_RETURN`.

    [Functions; there are none]

    02 00 00 00 00 00 00 00 - stack size
    00 - bgenerator
    01 00 00 00 00 00 00 00 - varparams
