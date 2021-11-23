use Test;
use _;

do {
    my class Sink is IO::Handle { has $.text;
        method WRITE($_) { $!text = .decode andthen True }
        method gist      { $!text }
        method Str       { $!text }
        submethod TWEAK  { self.encoding: 'utf8'}
    }

    my $msg = Sink.new;
    my $*ERR = $msg;
    my token file { '[' $($?FILE.IO.basename) ':' \d+ ']' <.ws> }

    dbg(my Int $i = 42).&is-deeply: 42,                       'Returns an Int argument';
    $msg.&like: / <file> 'Int $i = 42'/,                      'Prints an Int in a Scalar';
    dbg($i, 5).&is-deeply: (42, 5),                           'Returns a list argument';
    $msg.&like: / <file> '(Int $i=42, 5)'/,                   'Prints a list of (Scalar Int, Int)';
    dbg(1e0).&is-deeply: 1e0,                                 'Returns a Num argument';
    $msg.&like: / <file> '1e0'/,                              'Prints a Num';
    dbg($ = <1>).&is-deeply: <1>,                             'Returns an IntStr argument';
    $msg.&like: / <file> 'IntStr $ = IntStr.new(1, "1")'/,    'Prints an IntStr';
    dbg(<1 2 3>).&is-deeply: <1 2 3>,                         'Returns a list of IntStrs';
    $msg.&like: / <file> '(IntStr.new(1, "1"),' .* '"3"))'/,  'Prints a list of IntStrs ';
}
