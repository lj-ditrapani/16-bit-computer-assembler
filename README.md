Assembler for ljd 16-bit CPU
============================

The specification of the assembly language is in
[doc/assembly-language.md](https://github.com/lj-ditrapani/16-bit-computer-assembler/blob/master/doc/assembly-language.md).

The assembler prints the assembled machine code to standard out.
Redirect standard out to write to a file.

Usage:  `bin/assembler path/to/file.asm > path/to/file.exe`

It is a two pass assembler.  On the first pass, the assembler generates
a list of 'Commands' and fills in the symbol table.  On the second pass,
the assembler uses the list of Commands and the completed symbol table
to generate the actual machine code.

The machine code can be executed on the
[ljd 16-bit Computer](https://github.com/lj-ditrapani/16-bit-computer).
