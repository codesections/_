# _::Test::Fluent

Provides a thin (and currently incomplete) wrapper over the Core
[`Test`](https://docs.raku.org/type/Test) module that lets you write tests in a more fluent style
inspired by the [Fluent Assertions](https://fluentassertions.com/) (.NET’s) and
[Chai](https://fluentassertions.com/) (JS) packages.  Additionally, `Test::Fluent` lets you set the
descriptions for these tests in doc comments ([declarator
blocks](https://docs.raku.org/language/pod#index-entry-declarator_blocks_#=)) rather than as a
string:

```raku
# with Raku's Test:
unlike escape-str($str), /<invalid-chars>/,
    "Escaped strings don't contain invalid characters";

# with Test::Fluent:
#| Escaped strings don't contain invalid characters
{ escape-str($str) }.is.not.like: /<invalid-chars>/;
```

Specifically, `Test::Fluent` works by
[augmenting](https://docs.raku.org/language/typesystem#Augmenting_a_class) `Block`s with two
new methods.  (Note: in general, augmenting a built-in class is a very bad idea.  But doing so in
test code is significantly less likely to cause conflicts – I advise against using this approach
in non-test code).

The primary method that `Test::Fluent` adds is `.is`.  `.is` begins a test chain, letting you use
all of the test methods described below.  Once in the test chain, you can use the `.not` method to
invert the result of a test (i.e., results that would have passed now fail; those that would have
failed now pass).  The other method `Test::Fluent` adds to `Block`s is `.isn't`, which is simply a
contraction of `.is.not`.

Additionally, `Test::Fluent` re-exports `&plan`, `&done-testing`, `&subtest`, `&diag`, `&skip-rest`,
and `&bail-out` functions from the core `Test` module (because these functions do not logically
belong in a test chain).

## Provided methods

`Test::Fluent` currently provides the following methods for use in a test chain:

* `not`    - inverts the meaning of the test result
* `.true`  - is invocant true?
* `.ok`    - synonym for `.true`
* `eq`     - is the invocant `eq` (as a `Str`) to the `Str` argument?
* `like`   - is the invocant a match for the `Regex` argument?
* `eqv`    - is the invocant `eqv` to the argument?
* `deeply` - synonym for `.eqv`

Note: This list is incomplete/a WIP; the plan is to also wrap the remaining functions from the core
`Test` module.
