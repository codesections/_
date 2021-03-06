unit module Self::Recursion;

class X::_::Unsupported is Exception is export {
    method message { "Sorry, multis with no proto (or with an onlystar proto) don't currently\n"
                     ~"work with \&_.  Either use \&?ROUTINE instead, or add a proto with " ~ '{{*}}' }
}

#| Proxy to store the &calling-fn the first time we get it (to avoid walking the callframe each time)
sub ROUTINE is rw {
    my &calling-fn;
    Proxy.new: FETCH => method ()           { &calling-fn },
               STORE => method (&new is raw){ &calling-fn = &new }}

my $fn := ROUTINE;
our proto term:<&_>(|) is export {*}
multi term:<&_> {
    if callframe(1).code.?multi.not                        { $fn = callframe(1).code   }
    elsif callframe(1).code.name eq callframe(2).code.name { $fn = callframe(2).code   }
    else                                                   { die X::_::Unsupported.new }
    $fn
};
