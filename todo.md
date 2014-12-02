- Must add .array-fill to misc.asm misc.exe etc
- Move test code inside the Assembler module?
- Use Assembler::Directives::XxxxDirective to describe tests?
- Remove call to super() in Command subclasses if not needed
- Remove `Command#machine_code` when no longer needed
- Error-handling for .set directive (if value is not a non-negative
  integer and not a previously-defined symbol)
- Refactor token symbol code in `.set_directive` into a
  SymbolTable class
- `to_int` error handling:  forbid negative values
- Re-organize tests to match file hierarchy
- Fix rubocop offenses
- PseudoInstructions
    - specs for pseudoInstructions
- `acceptance_spec.rb` Create a full program test that includes
  NOP, fill-array, str, long-string, include, and copy
- Refactor directive classes
    - package last 3 asserts into a function?
- .long-string:  write specs for failing cases
- Consider adding .pstr and .long-pstring directives to allow for
  strings with packed 2 bytes per word.
  Could rename current .str and .long-string to .wstr and .long-wstring
  to stand for "wide string" since each char is 16-bits.
