## _::Pattern::Match

This package provides the `&choose` function, which allows pattern-matching using Raku's [signature
destructuring](https://docs.raku.org/type/Signature#Destructuring_arguments) as a more-powerful
alternative to smartmatch's [partial pattern
matching](https://docs.raku.org/language/syntax#Signature_literals). `&choose` takes a list of
blocks and runs the first block with a signature that matches the current
[topic](https://docs.raku.org/language/variables#index-entry-topic_variable).

Because `&choose` uses signature destructuring, it supports binding to elements of the
sub-signature.  Thus, instead of this:

```raku
# Without Pattern::Match
for (:add(1, 5), :sub(9, 8), :mult(7, 7)) {
    when .key eq 'add' {
        say "{.value[0]} + {.value[1]} is {sum .value}" }
    when .key eq 'sub' {
        say "{.value[0]} - {.value[1]} is {[-] .value}" }
    when .key eq 'mult' {
        say "{.value[0]} × {.value[1]} is {[×] .value}" }
    default  { die "Unknown op: $_" }
}
```

You can write:

```raku
use _ <&choose>;
for (:add(1, 5), :sub(9, 8), :mult(7, 7)) {
    choose -> :$add  ($a, $b) { say "$a + $b is {$a+$b}" },
           -> :$sub  ($a, $b) { say "$a - $b is {$a-$b}" },
           -> :$mult ($a, $b) { say "$a × $b is {$a×$b}" },
           -> |cap            { die "Unknown op: " ~|cap }
}
```

`&choose` can work especially well with [formal
parameters](https://docs.raku.org/language/variables#index-entry-twigil_$:) and [automatic
signatures](https://docs.raku.org/language/functions#index-entry-@__).  Using those features, you
could re-write the expression above as:


```raku
for (:add(1, 5), :sub(9, 8), :mult(7, 7)) {
    choose { say "$:add[0] + $:add[1] is {  [+] $add}"     },
           { say "$:sub[0] - $:sub[1] is {  [-] $sub[*]}"  },
           { say "$:mult[0] × $:mult[1] is {[×] $mult[*]}" },
           { die "Unknown op: " ~@_                        }
}
```

As with signatures, you can match against literals. Matches are evaluated from top to bottom (just
as with `given`/`when`), so you can place more specific cases above more general ones:

```raku
my $today = Date.new: '2021-12-11';
say do given $today {
    choose -> $ (12 :$month, 25 :$day, |)          { "Merry Christmas!" },
           -> $ (12 :$month, :$day where 26..*, |) { "I hope you had a nice Christmas :)" },
           -> | { "Only {359 - .day-of-year} days 'till Christmas" }
    }
```

But if you put a more general type above specific type, it could make it impossible to match the
more specific type.  This is known as "shadowing"; `&choose` will throw an error if it detects a
shadowed case:

```raku
my $today = Date.new: '2021-12-11';
say do given $today {
    choose -> | { "Only {359 - .day-of-year} days 'till Christmas" },
           -> $ (12 :$month, 25 :$day, |)          { "Merry Christmas!" },
           -> $ (12 :$month, :$day where 26..*, |) { "I hope you had a nice Christmas :)" },
    }

# THROWS with this message:
#   The pattern
#     ($ (Int :$month where { ... }, Int :$day where { ... }, |))
#   will never be matched because it is entirely shadowed by the prior pattern
#     (|)
```

`&choose` will also throw an error if the topic does not match any of the cases.  If you want to
allow non-matching input, you can set a default pattern with `-> |` (as in the prior example).

When you provide conditions for `&choose`, you are passing a list of `Block`s to a function.  This
means that, unlike `when` blocks, the conditional blocks must use [list
syntax](https://docs.raku.org/language/list#Literal_lists) – that is, in the examples above, the
**trailing commas are required** (except after the last block).

If you don't care for the look of the `,`, you Raku allows you to separate list items with `;` so
long as it's clear that the semicolon isn't ending a statement.  Here, this means using
parenthesizes to call `&choose`; using this syntax, the first example could be written as:

```raku
for (:add(1, 5), :sub(9, 8), :mult(7, 7)) {
    choose( { say "$:add[0] + $:add[1] is {  [+] $add}"     };
            { say "$:sub[0] - $:sub[1] is {  [-] $sub[*]}"  };
            { say "$:mult[0] × $:mult[1] is {[×] $mult[*]}" };
            { die "Unknown op: " ~@_                        })
}
```

In all of the examples above, `&choose` has matched against `$_` (the current topic), which is its
default behavior.  But if you want it to match on some other value, you can pass that value with the
`:on` named parameter.
