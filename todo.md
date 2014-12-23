Refactoring ideas

- Move README.md to doc/assembly-language.md and create new README.md
  that covers usage and design and refers to assembly-language.md

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
- .long-string:  write specs for failing cases
- Negative values get treated like symbols because they don't start
  with a digit, a $ or a %
- `to_int` error handling:  forbid negative values

Future Improvements

- Consider adding .pstr and .long-pstring directives to allow for
  strings with packed 2 bytes per word.
  Could rename current .str and .long-string to .wstr and .long-wstring
  to stand for "wide string" since each char is 16-bits.
