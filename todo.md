- Remove call to super() in Command subclasses if not needed
- Remove `Command#machine_code` when no longer needed
- Error-handling for .set directive (if value is not a non-negative
  integer and not a previously-defined symbol)
- `to_int` error handling:  forbid negative values
- Re-organize tests to match file hierarchy
- Fix rubocop offenses
- PseudoInstructions
    - specs for pseudoInstructions
    - refactor pseudoInstructions (return machine code)
- Refactor directive classes
    - package last 3 asserts into a function?
- .long-string:  write specs for failing cases
- Consider adding .pstr and .long-pstring directives to allow for
  strings with packed 2 bytes per word.
  Could rename current .str and .long-string to .wstr and .long-wstring
  to stand for "wide string" since each char is 16-bits.
- Make Assembler a class instead of a module?
  Attach asm, commands and symbol table to instance
- Create fail acceptance tests:
    - Write assembly programs that should trigger exceptions
    - Put asm programs in assembly-programs/failures directory
    - Write `acceptance_fail_spec.rb` with hash mapping
      file-name -> exception message regex.
      For each hash entry, assemble progam while expecting failure.
- Run rubocop
- Spell out .str and .long-string tests' expected results; provide
  the actual expected machine code for the tests.
- What happens if you have a comment or an empty line in the middle
  of an .array or .long-string??
- Move test code inside the Assembler module?
- Use Assembler::Directives::XxxxDirective to describe tests?
- Learn rake
- Move all test assets (assembly programs, expected output, etc)
  int spec folder.  Have to update all tests to run correctly.
