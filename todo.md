- Use Assembler::Directives::XxxxDirective to describe tests?
- Remove `unless command.nil?` check once commands implemented
- Remove call to super() in Command subclasses if not needed
- Remove `Command#machine_code` when no longer needed
- Error-handling for .set directive (if value is not a non-negative
  integer and not a previously-defined symbol)
- Refactor token symbol code in `.set_directive` into a
  SymbolTable class
- `to_int` error handling:  forbid negative values
- Re-organize tests to match file hierarchy
- Fix rubocop offenses
