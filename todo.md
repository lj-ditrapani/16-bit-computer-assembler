Refactoring ideas

- Separate branch: refactor
- Line class:  pass line as argument in place of
  `first_word` & `args_str` for `create_command`, `handle` method
  and anywhere else needed.
- Change Assembler module to Assembler class
  Make Assembler a class instead of a module?
- Assembler class has source, commands and `symbol_table` instance vars
- Assembler.rb has many methods only called from one other method.
  Create Helper module inside Assembler and put all "private" methods
  there?  Then prefix class with `Helper.<message>`
- For each set of methods only called by one method, create module
  or class as separate namespace (class if parameter list is long)
- Refactor methods with long parameter list into class with
  new that takes first parameters and then method that takes rest
- Possibly break `Symbol_table`, `Source`, and `CommandList` classes
  into their own files (one file per class)
- SourceInfo class:
  Command should also have a `source_info` object to hold
  line number and file name & return `error_info`.

Less pressing

- Move README.md to doc/assembly-language.md and create new README.md
  that covers usage and design and refers to assembly-language.md
- Command superclass used by WRD & directives

Spec related refactoring

- Spell out .str and .long-string tests' expected results; provide
  the actual expected machine code for the tests.
- Move test code inside the Assembler module?
- Use Assembler::Directives::XxxxDirective to describe tests?
- Refactor `directives_spec`
    - package last 3 asserts into a function?

Extra specs

- PseudoInstructions - Specs for pseudoInstructions


Error handling

- Create fail acceptance tests:
    - Write assembly programs that should trigger exceptions
    - Put asm programs in assembly-programs/failures directory
    - Write `acceptance_fail_spec.rb` with hash mapping
      file-name -> exception message regex.
      For each hash entry, assemble progam while expecting failure.
- .long-string:  write specs for failing cases
- Error-handling for .set directive (if value is not a non-negative
  integer and not a previously-defined symbol)
- `to_int` error handling:  forbid negative values
- Each command needs to hold the file name and line number of source
  line to give better error messages


Future Improvements

- Consider adding .pstr and .long-pstring directives to allow for
  strings with packed 2 bytes per word.
  Could rename current .str and .long-string to .wstr and .long-wstring
  to stand for "wide string" since each char is 16-bits.
