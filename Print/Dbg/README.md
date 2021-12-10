# _::Print::Dbg

Provides the `dbg` function, an alternative to `say .raku` or Rakudo's
[`&dd`](https://docs.raku.org/programs/01-debugging#index-entry-dd).  `&dbg` accepts one or more Raku
expressions and prints the value of those expressions and the line on which it was called:

```raku
# In file `example.raku` with this as line 1
dbg(42, 5, 'foo'.uc, 1+1);
# OUTPUT: «[example.raku:2]  (42, 5, "FOO", 2)»
```

When passed variables, `&dbg` will print information about the variables names:

```raku
my $i = 42;
my @a = <a b c>;
dbg($i, @a);
[example.raku:3]  (Int $i=42, Array @a=["a", "b", "c"])
```

The biggest difference between `&dbg` and `&dd` is that `&dbg` returns the value(s) it was called
with, which lets you print an expression without preventing other parts of the code from using that
expression.  For example, you can use `&dbg` to see the value of `&arg` in the expression below
without interfering with the call to `&some-function`


```raku
sub some-function($arg1, dbg($arg2), $arg3);
```
