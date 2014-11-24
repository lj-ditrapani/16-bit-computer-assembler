<!-- ====|=========|=========|=========|=========|=========|======== -->
LJD 16-bit CPU Assembly Language
================================


Comments
--------

Use # to comment a line.
```
# this is a comment
HLT   # comment at end of line
```
Comments can be placed on any line except on lines between
.long-string and .end-long-string directives.


Numbers
------
```
Numbers are unsigned integers
An unadorned integer represents a decimal value
$ represents a hex value $D7E0
% represents a binary value %0101_1100_1011
underscores in numbers are ignored
```


Predefined symbols
------------------

```
R0-RF
or
R0-R15
for registers

tiles
grid
cell-xy-flips
sprites
sprite-colors
cell-colors
audio
net-out
net-in
storage-out
storage-in
keyboard
net-status
enable-bits
storage-read-address
storage-write-address
frame-interrupt-vector
```


Directives
----------
Directives start with .

- .set
- .word
- .array
- .fill-array
- .str
- .long-string
- .end-long-string
- .move
- .include
- .copy

### .set ###
```
Sets a variable to a constant value
.set var_name value
.set var_name 7     # var_name is replaced with 7 wherever it occurs
```

### .word ###
```
.word InitValue     # put InitValue at current address in program
.word 42
(x)
.word 42     # x now refers to address which contains value 42
```

### .array ###
```
Array reserves multiple consecutive slots in memory and sets the slots
to specific values.  The values are listed between brackets [] and
delimited by whitespace.
.array [list of whitespace delimited unsigned integers]
.array [1 2 3]
Array values are free-form within the brackets []
.array [
    $F0 $F1 $F2 $F3     # First 4 words
    $F4 $F5 $F6 $F7     # Last 4 words
]
# Array with 9 mixed-representation numbers; 3 pre line
.array [
    %0101_0000_1111_1010 $FEED 16
    %1111_0000_1111_1010 $FACE 32
    %0000_1111_1111_0101 $BACE 64
]

```
### .fill-array ###
```
The f
.fill-array size fill
(my_array)
.array 16 0  # my_array now refers to first address of 16-element array
             # initialized to all zeros
.array 4 $FF # Creates an array of 4 values of 255
```

### .str ###
A string is a sequence of 7-bit ASCII characters.  Two characters are
packed into a word.  The first character in the high-order byte and the
second character into the low-order byte.
```
.str "Hello World"  # a string
(greet)             # The symbol points to the next word in memory
.str "Hello Joe"    # a string; can be referred to by greet symbol
```
The .str directive and the string must fit on a single line.
Use the .long-string directive for multi-line strings
```
.str "one two three"
.str "c"
.str "embedded \" in string"
.str "\"Hi\" she said"
Use two \\ to represent a \
.str "win\\path\\file.txt"
.str "\n\t\r" special chars newline, tab
```

### .long-string ###
Begins a multi-line string

Format:

    .long-string (literal-newlines|escaped-newlines)

With literal-newlines, the '\n' char is appended to each line

    .long-string literal-newlines
    line one
    line two
    line three
    .end-long-string

With escaped-newlines, the newlines at the end of each line are stripped
and the only way to have a newline is to explicitly use the escape
sequence '\n'.

    .long-string escaped-newlines
    line one
    still line one \n now line two
    still line two
    .end-long-string

### .end-long-string ###
Ends a multi-line string (see .long-string above for examples)

### .move ###
Assembler moves context to specified address during assembly.
Can only move forward in address space from current address,
not backwards.  Cannot use symbols that refer to labels. The argument
must be a number, a pre-defined symbol, or a symbol previously defined
by a .set directive.
If the argument is a symbol defined by the .set directive, the .set
directive must appear before the .move command.
Zero fills holes in binary machine code.
```
.move $0F00
.move audio
```

### .copy ###
Copies binary content of file directly into final assembled binary
starting at current location.
Optionally takes start and end values for binary file
start defaults to 0 and end defaults to end of file
start and end are in terms of 16-bit words in file

```
.copy path/file-name.ext [start [end]]
.move tiles
.copy video/mario-tiles.bin
.copy text/story.txt  # copies data into ram starting at current address
.copy video-data.bin $400
.copy video-data.bin $400 $4FF  # copy 255 words starting at $400
```

### .include ###
Includes the assembly text lines of the file referred to by
the `.include` directive.  The lines are inserted at the current
location of the assembly lines.  The assembler then processes the
lines normally.  This allows for recursive includes (includes of files
that include other files, etc.)
```
.set math-library $9000
.include path/to/program.asm    # includes it here
.move math-library
.include path/to/math-lib.asm
```


Labels
------
```
Labels are symbols surrounded with ()
(label_name)
labels go on separate lines by themselves
The value of a label is the memory address of the line below it

One label per line

Use a label to name an address
Works for both code (jumps) and data (variable names)
```


Symbols
-------
Labels and variables are named with symbols.
Symbols start with a letter and can contain letters, numbers, - and \_.


Pseudo Instructions
-------------------
```
pseudo        |   Actual assembled instructions
------------------------------------------------
CPY R1 R2     |   ADI R1 0 R2
NOP           |   ADI R1 0 R1
WRD $1234 R7  |   LBY $34 R7   HBY $12 R7
INC R3        |   ADI R3 1 R3
DEC R3        |   SBI R3 1 R3
JMP R3        |   BRN R0 R3 NZP
```


Assembly Format of the 16 Operations
------------------------------------
```
END
HBY i8 R
LBY i8 R
LOD R  R
STR R  R
ADD R  R  R
SUB R  R  R
ADI R  i4 R
SBI R  i4 R
AND R  R  R
ORR R  R  R
XOR R  R  R
NOT R  R
SHF R  D  A  R
BRN R  value-condition R
BRN flag-condition R
SPC R

Legend
---------------------------------------------------------------------
i4                  4-bit unsigned integer
i8                  8-bit unsigned integer
R                   Register number 0-15 (R0-R15 & RA-RF are symbols)
D                   Direction (L or R)
A                   Shift amount (1-8)
value-condition     any combination of [NZP]
flag-condition      any sigle character of [-CV]
---------------------------------------------------------------------
```


Examples
--------
Examples of how to write the different instructions with the assembled
hexadecimal output in the comments on the right.
```
Set high byte of RA to 255
HBY $FF RA      #  $1FFA
HBY 255 R10     #  $1FFA

Set low byte of R5 to 16
LBY $10 R5      #  $2105
LBY 16 R5       #  $2105

Load R3 with value at memory address in R9
LOD R9 R3       #  $3903

Store at the memory address in RF the value of R1
STR RF R1       #  $4F10

Add value in RE to value in R6 and store in RA
ADD RE R6 RA    #  $5E6A
ADD R14 R6 R10  #  $5E6A

Same format for SUB, AND, ORR, XOR as ADD

Add value in R3 to 15 and store in R0
ADI R3 $F R0    #  $73F0
ADI R3 15 R0    #  $73F0

Same format for SBI as ADI

Not value in RA and store in RB
NOT RA RB       #  $CA0B

Shift the value in R7 left by 2 and store in RA
SHF R7 L 2 RA   #  $D71A
SHF R7 L 2 R10  #  $D71A

Shift the value in R5 right by 7 and store in R0
SHF R5 R 7 R0   #  $D5E0

If value in R7 is negative or zero, PC = value in RB
BRN R7 NZ RB    #  $E7B6
If both carry and overflow flags are *NOT* set, jump to address in R8
BRN - RB        #  $E0B8
If carry flag is set, jump to address in R8
BRN C RB        #  $E0B9
If overflow flag is set, jump to address in R8
BRN V RB        #  $E0BA

Add 2 to current PC and save result in R5
SPC R5          #  $F005
```
