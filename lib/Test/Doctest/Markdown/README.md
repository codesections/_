# _::Test::Doctest::Markdown

Provide `&doctest` that tests Raku code contained in a Markdown file (typically a README)
`&doctest`'s primary purpose is to run examples in READMEs and other documentation to ensure that
all examples compile and run – nothing’s worse than broken examples!

`&doctest` scans the Markdown file for any [fenced code
blocks](https://spec.commonmark.org/0.30/#fenced-code-blocks) with 'raku' in their [info
string](https://spec.commonmark.org/0.30/#info-string) and tests the code in each block.

If the code block has `OUTPUT: «…»` comments, `&doctest` captures the code’s output and tests it
against the expected output; if the code block doesn’t have `OUTPUT` comments, `&doctest` tests
whether the code can be `EVALed` ok.

`&doctest` also supports adding configuration info by preceding the code block with a
`<!-- doctest -->` comment; currently, the only config option is to provide setup code that’s run as
part of the test without being displayed in the Markdown file; in the future, this will likely
include more option, such as expecting tests to fail.
