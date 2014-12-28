Refactoring ideas

Error handling

- SymbolTable:  do not allow reserved words as symbols
  (no directives, instructions, or pseudo-instructions)
  (what about LR, NZP, CV-, strip-newlines, keep-newlines
- Negative values get treated like symbols because they don't start
  with a digit, a $ or a %
- BRN value condition:  NZZ, NNNN, PZP will all pass without error.
  Not worth checking?  Currently only check with /^[NZP]+$/ regex.

Spec related refactoring

- Spell out .str and .long-string tests' expected results; provide
  the actual expected machine code for the tests.
- Move test code inside the Assembler module?

Future Improvements

- Consider adding .pstr and .long-pstring directives to allow for
  strings with packed 2 bytes per word.
  Could rename current .str and .long-string to .wstr and .long-wstring
  to stand for "wide string" since each char is 16-bits.
