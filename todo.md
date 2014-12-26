Refactoring ideas

- Move README.md to doc/assembly-language.md and create new README.md
  that covers usage and design and refers to assembly-language.md

Error handling

- Create fail acceptance tests:
    - Write assembly programs that should trigger exceptions
- Args class:  `Args.new(format).parse(agrs_str)`.
  Format: space delimited string of format tokens.
  Format tokens:
    - - (appears alone) No args, `args_str = ''`
    - * (appears alone) Don't parse, just return raw `args_str`
    - S Element is special, return raw string
    - T Element is 16-bit token
    - 8 Element is 8-bit token
    - 4 Element is 4-bit token
    - F Element is a file name; check if file exists
- Wrong number of args for instructions, directives, etc
    - Add `parse_args(format, args_str)` method to Command
      Args.new(format).parse(args_str)
    - fails w/msg if count does not match on split
        - *   option:  for array and str
        - -   option:  checks args_str == nil
        - 1+  option:  args_str.split.size == count
    - Directives        num
        - .set          2
        - .word         1
        - .array        *
        - .fill-array   2
        - .str          *
        - .long-string  1 (non-token; key-word)
        - .move         1
        - .include      1 (non-token; file)
        - .copy         1 (non-token; file)
    - .copy, .include:  file exits error
    - bin/assembler     file exits error
    - pseudo-instructions
        - NOP           0
        - INC/DEC/JMP   1
        - CPY/WRD       2
- SHF and BRN have special, non-token args, need special errors
- BRN can have 2 or 3 args (do * format)
- Register (R) arguments must be 0-15
- i4 arguments must be 0-15
- i8 arguments must be 0-255
- SHF ammount will have special check SHF class (must be 1-8)
  SHF asks Token for 16-bit value, then does own check with result
- All others are 16-bit 0x0000-0xFFFF
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
