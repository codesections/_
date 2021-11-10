unit module Recursion;

## Dynamic var approch - slowest (~ 10s for 1000 fn calls)
our &_ is dynamic is export =  {
    my &outer;
    if callframe(1).code.?multi.not                        { &outer = callframe(1).code }
    elsif callframe(1).code.name eq callframe(2).code.name { &outer = callframe(2).code }
    else                                                   { die "no proto-TODO error" }


    &outer.wrap: sub (|c) { my &_ is dynamic = nextcallee;
                            &_(|c)}
    outer $_;
}
