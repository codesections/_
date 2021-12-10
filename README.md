# `_`

`_` (pronounced "lowbar") is a meta utility package for the [Raku](https://raku.org) programming
language.  Being _meta_ means that `_` is comprised of independent sub-packages, each with their own
documentation and tests.  Being a _utility_ package means that each of `_`'s sub-packages is
provides some helper functionality — the type of functionality that, if it weren't in `_`, might
live in a `./utils` directory or in a tiny module that would bloat your dependency tree.

`_`'s goal is to provide you with utilities that are [correct by
inspection](https://proofwiki.org/wiki/ProofWiki:Jokes#Proof_by_Inspection): that is, with code so
simple that you can look at it and _tell_ that it is correct.  To achieve this goal, each `_`
sub-package will always be:

  1. A single file (not counting tests/docs)
  2. With zero dependencies (not counting other `_` files or [core
     modules](https://docs.raku.org/language/modules-core))
  3. That's no more than 70 lines long

This means that you or any other Raku programmer can evaluate any `_` sub-package by opening a
single file and reading a page of code.  If you have questions or concerns about any `_`
sub-packages, I encourage you to do just that.

However, just because you can doesn't mean that you must: each `_` sub-package is also documented in
the accompanying `README` file located in its directory.  Similarly, as valuable as "proof by
inspection" my be, it's no substitute for tests. (Recall [Knuth's
warning to a colleague](https://www-cs-faculty.stanford.edu/~knuth/faq.html): "Beware of bugs in the above code; I
have only proved it correct, not tried it.**).  Accordingly, each sub-package also has its own tests.

**NOTE**: Once `_` has a production release, it will guarantee backwards compatibility.  However,
`_` is currently beta software and does **not promise backwards compatibility**.

For more information about `_`'s goals and plans, please see the [announcement blog
post](https://raku-advent.blog/unix_philosophy_without_leftpad_part2).

## Installation

Install `_` with `$ zef install _:auth<github:codesections>`.

## Usage

To use `_`, you can import all of `_`'s exported functions with `use _`. This style of
importing is intended for prototyping/experimentation when you are not which `_` functions you may use.

Alternatively, you can selectively import exported functions (or other symbols) by passing their
name to the `use _` statement.  For example, here's how you could import the `&dbg` function from
the `Print::Dbg` sub-package and the `&wrap-words` function from the `Text::Wrap` sub-package:

```raku
use _ <&dbg &wrap-words>;
```

This style of imports is intended for later in the development process/when you want to ensure that
`_` does not cause unexpected name clashes.

## sub-packages

`_` includes the following sub-packages.  You can find more information about each one in
the `README` file in its directory.

  * `Pattern::Match` - pattern match with Raku's full destructuring from signature
    binding. [README](./Pattern/Match/README.md); [src](./Pattern/Match/Match.rakumod)

  * `Print::Dbg` - better print-line debugging than `.raku` or
    `dd`. [README](./Print/Dbg/README.md); [src](./Print/Dbg/Dbg.rakumod)

  * `Self::Recursion` - provides `&_` as an alias for `&?ROUTINE` for anonymous self-recursion.
    [README](./Self/Recursion/README.md); [src](./Self/Recursion/Recursion.rakumod)

  * `Text::Paragraphs` - provides a `paragraphs` function similar to
    [`lines`](https://docs.raku.org/routine/lines) except that it breaks text up into paragraphs
    rather than lines. [README](./Text/Paragraphs/README.md); [src](./Text/Paragraphs/Paragraphs.rakumod)

  * `Text::Wrap` - provides a `wrap-words` function that wraps text to a specified line length (a
    better alternative to Rakudo's private `naive-word-wrapper`). [README](./Text/Wrap/README.md);
    [src](./Text/Wrap/Wrap.rakumod)

  * `Test::Doctest::Markdown` - tests Raku code blocks from `README`s or other markdown files and,
    optionally, compares their output to `# OUTPUT: «…»`
    comments. [README](./Test/Doctest/Markdown/README.md); [src](./Test/Doctest/Markdown/Markdown.md)

  * `Test::Fluent` - A thin wrapper over [Test](https://docs.raku.org/type/Test) that lets you
    describe tests in [declarator
    comments](https://docs.raku.org/language/pod#index-entry-declarator_blocks_#=) (`#|`) and to
    more fluently chain test methods.[README](./Test/Fluent/README.md); [src](./Test/Fluent/Fluent.md)

## Contributing

You would be welcome to contribute to `_`'s development; you can help in any of the following ways:

  * by opening an issue
    - to report a section of the documentation that you found unclear
    - to report a bug in an existing sub-package
    - to suggest a feature for an existing sub-package
    - to suggest a new sub-package
    - to discuss future plans for `_`/and of the
      [questions from the announcement
      post](https://raku-advent.blog/unix_philosophy_without_leftpad_part2#future_plans)
  * by opening a pull request
    - to improve the documentation
    - to add tests for an exiting sub-package
    - to fix a bug
    - to add a feature for a sub-package
    - to add a new sub-package

  (For the last two, it'd probably be a good idea to mention your idea in an issue first; that's not
  a requirement, but it might prevent you spending time of a feature that isn't a great fit for `_`).

  All `_` contributors agree to abide by the [Raku Code of
  Conduct](https://raku.github.io/Raku-Steering-Council/papers/CoC).

## Roadmap

My initial goal for `_` is to get it to a 1.0.0/stable release as soon as possible in order to
provide guarantees regarding backwards compatibility.  To that end, my priority is to decide what
`_`'s overall approach to versioning will be and to implement that system. The [announcement blog
post](https://raku-advent.blog/unix_philosophy_without_leftpad_part2#versioning) has additional
details about the versioning considerations.

Once `_` has a stable release, the plan is to focus on growing `_` to address other needs in the
Raku ecosystem.
