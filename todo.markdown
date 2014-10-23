- Find ruby lint program
- Error-handling for .set directive (if value is not a non-negative
  integer and not a previously-defined symbol)
- Integer conversion code
    - Check first char
        - if \d digit -> Integer(str, 10)
        - if $, hex -> Integer(str, 16)
        - if %, bin -> Integer(str, 2)
