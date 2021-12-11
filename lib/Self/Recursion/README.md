# Self::Recursion

Provides the variable `&_` as a shorter alias for `&?ROUTINE`, which allows for more concise
anonymous recursion.  For example, you can define a naive Fibonacci function as

<!--doctest hidden => 'use _;' -->
```raku
sub fib(UInt $n) { $n == 0|1  ?? $n !! &_($n-1) + &_($n-2) }
say fib(5);           # OUTPUT: «5»
say (^11).map(&fib);  # OUTPUT: «(0 1 1 2 3 5 8 13 21 34 55)»
```

Using `&_` has the same advantages main advantages as using `&?ROUTINE` – namely that it clearly
expresses the intent to self-recourse, you don't need to change the name if you rename `fib`, and it
can be used in an anonymous function.  The only advantage `&_` provides over `&?ROUTINE` is a
shorter name (well, and that it completes the pattern created by [`$_`, `@_`, and
`%_`](https://docs.raku.org/language/functions#index-entry-@__)).


<!--doctest hidden => 'use _;' -->
```raku
sub f(UInt $n) { $n == 0|1  ?? $n !! &_($n-1) + &_($n-2) }
say f(5);           # OUTPUT: «85»
```

Please note that (as the lack of a `?` in its name indicates) `&_` is a run-time construct rather
than a compile-time one and thus has significantly worse performance than `&?ROUTINE`, specifically
in situations where an implementation would inline a call to `&?ROUTINE` (e.g., deeply recursive
calls to a simple function, such as `fib` from above).  Once Raku has stable support for
Raku-AST-based macros, I plan to add a `&?_` variable.  Until that time, you should avoid using `&_`
in performance-critical code/with very deep recursion.
