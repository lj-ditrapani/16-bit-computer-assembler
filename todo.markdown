- Readme:  Legend R -> actual number 0-15 or $0-$F or %0000-%1111
  (R0-R15 & RA-RF are just pre-defined symbols that map to 0-15)
- ADD SUB ADI & SBI instructions are identical minus op-code
- Use Assembler::Directives::XxxxDirective to describe tests?
- Refactor Instruction classes
    - Use Instruction base class with `def_init` and
      `def_machine_code` class methods that take a block and create
      instance methods via def_method
- Remove unless command.nil? check once commands implemented
- Remove call to super() in Command subclasses if not needed
- Remove `Command#machine_code` when no longer needed
- Find ruby lint program
- Error-handling for .set directive (if value is not a non-negative
  integer and not a previously-defined symbol)
- Refactor token symbol code in `.set_directive` into a
  SymbolTable class
- `to_int` error handling:  forbid negative values
- Re-organize tests to match file hierarchy
- Add `get_int(symbol_table)` method to Token
- Restore `spec/acceptance_spec.rb` "with-symbol" tests once
  "no-symbol" tests are passing
