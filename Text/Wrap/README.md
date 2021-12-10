# Text::Wrap

This module exports a single function, `word-wrap`, which wraps text
to a specified line length based on a simple greedy algorithm, and is
intended to be used to format simple text for terminal output (e.g.,
error messages or human-readable output for CLI programs.)  In
particular, is designed to provide an alternative to Rakudo's
[`Str.naive-word-wrapper`](https://github.com/rakudo/rakudo/blob/master/src/core.c/Str.pm6#L3614-L3659),
a method that is marked as an `implementation-detail` and thus
generally should not be relied on in production code.

`word-wrap` is designed to do what you (probably) mean if given
nothing but the text you want wrapped, which it will by default wrap to
a width of 80 characters.  For more customization, you can pass
additional options and can tell `word-wrap` to operate in one of four
modes.

options TODO.

Additionally, `word-wrap` can operate in the following four modes,
each of which can be activated by passing the corresponding named
argument.

In `:reflow-all` mode, `word-wrap` removes all line breaks in the text
and reflows it as a single block (this is the most direct equivalent
to `.naive-word-wrapper`).  In `:keep-paragraphs`, `word-wrap`
keeps preserves the breaks between paragraphs, but fully reflows each
paragraph.  In `:keep-newlines`, `word-wrap` does not remove any of
the line breaks in the text; all it does is wrap lines that are longer
than the maximum line length.

Finally, in `:smart` mode (the default) `word-wrap` attempts to do the
right thing based on contextual heuristics.  In general, this means
that it behaves like `:keep-paragraphs` unless it detects evidence
that a hard line break has semantic meaning (e.g., it appears to be
part of a bulleted list).
