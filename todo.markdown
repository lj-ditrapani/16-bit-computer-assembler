- .move directive tests
- .work directive tests
- Refactor Instruction classes
    - Use Instruction base class with `def_init` and
      `def_machine_code` class methods that take a block and create
      instance methods via def_method
- .word directive:
  if using a symbol as the target address, must resolve symbol
  to compute the `word_length`
- Remove if in Instructions#handle once instructions are complete
- Remove unless command.nil? check once commands implemented
- Remove call to super() in Command subclasses if not needed
- Remove `Command#machine_code` when no longer needed
- Find ruby lint program
- Error-handling for .set directive (if value is not a non-negative
  integer and not a previously-defined symbol)
- Refactor token symbol code in `.set_directive` into a
  SymbolTable class
- `to_int` error handling:  forbid negative values
- Re-organise tests to match file hierarchy
- Split tests into multiple files
- Add `get_int(symbol_table)` method to Token
- Restore `spec/acceptance_spec.rb` "with-symbol" tests once
  "no-symbol" tests are passing
