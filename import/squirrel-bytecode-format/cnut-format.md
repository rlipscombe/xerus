# `.cnut` file format

Squirrel source code is saved in `.nut` files. These are saved as squirrel bytecode (compiled nut) in `.cnut` files.

Given the following squirrel source code:

    print("Hello World!\n");

You can compile it with:

    sq -c -o hello.cnut hello.nut

This results in the following `.cnut` file:

    00000000: fafa 5249 5153 0100 0000 0800 0000 0400  ..RIQS..........
    00000010: 0000 5452 4150 1000 0008 0900 0000 0000  ..TRAP..........
    00000020: 0000 626c 616e 6b2e 6e75 7410 0000 0804  ..blank.nut.....
    00000030: 0000 0000 0000 006d 6169 6e54 5241 5000  .......mainTRAP.
    00000040: 0000 0000 0000 0002 0000 0000 0000 0000  ................
    00000050: 0000 0000 0000 0002 0000 0000 0000 0001  ................
    00000060: 0000 0000 0000 0000 0000 0000 0000 0001  ................
    00000070: 0000 0000 0000 0000 0000 0000 0000 0054  ...............T
    00000080: 5241 5054 5241 5010 0000 0804 0000 0000  RAPTRAP.........
    00000090: 0000 0074 6869 7310 0000 0805 0000 0000  ...this.........
    000000a0: 0000 0076 6172 6776 5452 4150 5452 4150  ...vargvTRAPTRAP
    000000b0: 1000 0008 0500 0000 0000 0000 7661 7267  ............varg
    000000c0: 7601 0000 0000 0000 0000 0000 0000 0000  v...............
    000000d0: 0000 0000 0000 0000 0010 0000 0804 0000  ................
    000000e0: 0000 0000 0074 6869 7300 0000 0000 0000  .....this.......
    000000f0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
    00000100: 0054 5241 5001 0000 0000 0000 0000 0000  .TRAP...........
    00000110: 0000 0000 0054 5241 5054 5241 5000 0000  .....TRAPTRAP...
    00000120: 0017 ff00 0054 5241 5002 0000 0000 0000  .....TRAP.......
    00000130: 0000 0100 0000 0000 0000 4c49 4154       ..........LIAT

This breaks down as follows:

    FA FA - SQ_BYTECODE_STREAM_TAG

Closure:

    52 49 51 53 - SQ_CLOSURESTREAM_HEAD - 'RIQS' - 'SQIR' backwards, because little-endian.
    01 00 00 00 - sizeof(SQChar)
    08 00 00 00 - sizeof(SQInteger) - 64-bit integers
    04 00 00 00 - sizeof(SQFloat) - 32-bit (single-precision) floats
    [Function Proto]
    LIAT

Every squirrel program has an implicit `main` function, and all of the other functions are nested within this.
    
Function Proto:

    54 52 41 50 - TRAP (PART backwards)
    [source: OT_STRING 'blank.nut']

`OT_STRING` object:

    10 00 00 08 - type = OT_STRING
    09 00 00 00 00 00 00 00 - length = 9
    62 6c 61 6e 6b 2e 6e 75 74 - 'blank.nut' (no NUL)

    [name: OT_STRING 'main']

    54 52 41 50 - TRAP (PART backwards)
    00 00 00 00 00 00 00 00 - nliterals
    02 00 00 00 00 00 00 00 - nparameters
    00 00 00 00 00 00 00 00 - noutervalues
    02 00 00 00 00 00 00 00 - nlocalvarinfos
    01 00 00 00 00 00 00 00 - nlineinfos
    00 00 00 00 00 00 00 00 - ndefaultparams
    01 00 00 00 00 00 00 00 - ninstructions
    00 00 00 00 00 00 00 00 - nfunctions

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

    [Functions; there are none]

    02 00 00 00 00 00 00 00 - stack size
    00 - bgenerator
    01 00 00 00 00 00 00 00 - varparams
