<!-- ====|=========|=========|=========|=========|=========|======== -->
LJD 16-bit CPU Assembly Language
================================

This is a WIP; incomplete.


Comments
--------

Use # to comments a line
```
# this is a comment
HLT   # comment at end of line
```


Numbers
------
```
unadorned integer represents a decimal value
if preceeded by a -, converted to 2-complement
$ represents a hex value $D7E0
% represents a binary value %0101_1100_1011
underscores in numbers are ignored
@ for octal
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
keyboard
sound
net-out
net-in
storage-out
storage-in
```


Strings
-------
```
"one two three"
"c"
"embedded \" in string"
"\"Hi\" she said"
Use two \\ to represent a \
"win\\path\\file.txt"
"Bin number \%0101  Hex number \$AOU"
"\n\t\r" special chars newline, tab
```

Directives
----------
Directives start with .

- .set
- .word
- .array
- .string
- .include
- .inject insert or copy??
- .move

### .set ###
```
Sets a varible to a constant value
.set var_name value
.set var_name 7     # var_name is replaced with 7 wherever it occurs
```

### .word ###
```
.word InitValue     # put InitValue at current address in program
.word 42
(x)
.word 42     # x now reffers to address which contains value 42
```

### .array ###
```
.array size fill
(my_array)
.array 16 0  # my_array now reffers to first address of 16-element array
```

### .string ###
```
.str "Hello World"  # a string
(greet)
.str "Hello Joe"    # a string; can be reffered to by greet symbol
```

### .inject .insert or copy??? ###
Copies binary content of file directly into final assembled binary
at specified address
(or at current location if no address is specified).
Zero fills holes in file

```
.copy path/file-name.ext address
.copy video/mario-tiles tiles
.copy story.txt $9000
.copy text/story.txt  # copies data into ram starting at current address
```
<!--
# probably not:
# .word and .array only valid under .static section
-->


### .include ###
Processed during first pass.  Includes the assembly text
of all .include directives.  Then the assembler processes the
total file as one big file.  Not recursive.
```
.include path/to/program.asm    # includes it here
.include path/to/program.asm address
```


### .move ###
<!-- Do you really need this, include and copy? -->
Assembler moves context to specified address during assembly
```
.move $0F00
.move audio
```

Labels
------
```
Labels/symbols are surrounded with ()
(label_name)
labels go on separte lines by them selves

One instruction/label per line

Name an address with a label/symbol
works for both code (jumps) and data (variable names)
```

Pseudo operations
-----------------
```
CPY R1 R2     ->  ADI R1 0 R2
NOP           ->  ADI R1 0 R1
WRD $1234 R7  ->  LBY $34 R7 HBY $12 R7 
```

<!--
Could have format
ADD R1 R2 -> R3
or
ADD R1 R2 R3
-->

<!--
16 Operations
=============


0 HLT    Halt
Halt computer
HLT         ->  $0000


1 LBY    Low byte
RD[07-00] <- immd8
Set low byte of R5 to 16
LBY $10 R5  ->  $1105
LBY 16 R5   ->  $1105


2 HBY    High byte
RD[15-08] <- immd8
Set high byte of RA to 255
HBY $FF RA  ->  $2FFA
HBY 255 R10 ->  $2FFA


3 LOD    Load
RD <- M[R1]
Load R3 with value at memory address in R9
LOD R9 R3   ->  $3903


4 STR    Store
M[R1] <- R2
Store at the memory address in RF the value of R1
STR RF R1   ->  $4F10


5 ADD
RD <- RS1 + RS2

  
6 SUB
RD <- RS1 - RS2


7 ADI    Add 4-bit immediate
RD <- RS1 + immd4


8 SBI    Subtract 4-bit immediate
RD <- RS1 - immd4


9 AND
RD <- RS1 and RS2


A ORR
RD <- RS1 or RS2
 
 
B XOR
RD <- RS1 xor RS2
  

C NOT
RD <- ! R1


D SHF    Shift
RD <- RS1 shifted by immd4
SHF  Shift, zero fill
Carry contains bit of last bit shifted out
immd4
DAAA
D is direction:  0 left, 1 right
AAA is (amount - 1)
0-7  ->  1-8
Assembly:
SHF R3 L 2 RA ->  $D31A
SHF R7 R 7 R0 ->  $D7E0


E BRN    Branch
PC <- R2 if R1 matches NZPCV
BRN M---
M is mode
0NZP    0 is value mode (negative zero positive)
10VC    1 is flag mode (overflow carry)
0111    unconditional jump
0000    no op


F SPC    Save PC
RD <- PC + 2



        Mm Reg  01 02 03
0 HLT    - --    0  0  0


3 LOD    R RW   RA  0 RD
4 STR    W R-   RA R2  0
5 ADD    - RW   R1 R2 RD
6 SUB    - RW   R1 R2 RD
7 ADI    - RW   R1 UC RD
8 SBI    - RW   R1 UC RD
9 AND    - RW   R1 R2 RD
A ORR    - RW   R1 R2 RD
B XOR    - RW   R1 R2 RD
C NOT    - RW   R1  0 RD
D SHF    - RW   R1 SC RD
E BRN    - RP   RV RP cond
F SPC    - RW    0  0 RD
-->
