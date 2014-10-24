- Find ruby lint program
- Error-handling for .set directive (if value is not a non-negative
  integer and not a previously-defined symbol)
- Refactor token symbol code in `.set_directive` into a
  SymbolTable class
- `to_int` error handling:  forbid negative values
