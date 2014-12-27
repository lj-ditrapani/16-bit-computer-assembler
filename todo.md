Refactoring ideas

- Correct documentation:  fill-array size can be a symbol, but must be
  predefined by previously occurring .set directive or label
- Move README.md to doc/assembly-language.md and create new README.md
  that covers usage and design and refers to assembly-language.md
- Flip assembly-language spec format around (start with instructions...)

Error handling

- Create fail acceptance tests:
    - Write assembly programs that should trigger exceptions
    - Number of args, type of args
- SHF and BRN have special, non-token args, need special errors
- SHF ammount will have special check SHF class (must be 1-8)
  SHF asks Token for 16-bit value, then does own check with result
- Need tests for SHF Direction (L/R) and ammount (1-8)
- BRN can have 2 or 3 args; use special error handling
- Special:  D(LR), value-condition(NZP), flag-condition(CV-)
  .long-string keep-newlines/strip-newlines
- SymbolTable:  do not allow reserved words as symbols
  (no directives, instructions, or pseudo-instructions)
  (what about LR, NZP, CV-, strip-newlines, keep-newlines
- Negative values get treated like symbols because they don't start
  with a digit, a $ or a %

Spec related refactoring

- Spell out .str and .long-string tests' expected results; provide
  the actual expected machine code for the tests.
- Move test code inside the Assembler module?

Extra specs

- PseudoInstructions - Specs for pseudoInstructions

Future Improvements

- Consider adding .pstr and .long-pstring directives to allow for
  strings with packed 2 bytes per word.
  Could rename current .str and .long-string to .wstr and .long-wstring
  to stand for "wide string" since each char is 16-bits.
