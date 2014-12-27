Assembler for ljd 16-bit CPU
============================

The specification of the assembly language is in
[doc/language-spec.md](https://github.com/lj-ditrapani/16-bit-computer-assembler/doc/language-spec.md).

It is a two pass assembler.  On the first pass, the assembler generates
a list of 'Commands' and fills in the symbol table.  On the second pass,
the assembler uses the list of Commands and the completed symbol table
to generate the actual machine code.

The machine code can be executed on the
[ljd 16-bit Computer](https://github.com/lj-ditrapani/16-bit-computer).
