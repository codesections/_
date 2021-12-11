unit module Test::Fluent;
need Test;
constant &plan          = &Test::EXPORT::DEFAULT::plan;
constant &done-testing  = &Test::EXPORT::DEFAULT::done-testing;
constant &subtest       = &Test::EXPORT::DEFAULT::subtest;
constant &diag          = &Test::EXPORT::DEFAULT::diag;
constant &skip-rest     = &Test::EXPORT::DEFAULT::skip-rest;
constant &bail-out      = &Test::EXPORT::DEFAULT::bail-out;

constant &ok            = &Test::EXPORT::DEFAULT::ok;
constant &nok           = &Test::EXPORT::DEFAULT::nok;
constant &is            = &Test::EXPORT::DEFAULT::is;
constant &isnt          = &Test::EXPORT::DEFAULT::isnt;
constant &is-approx     = &Test::EXPORT::DEFAULT::is-approx;
constant &is-deeply     = &Test::EXPORT::DEFAULT::is-deeply;
constant &cmp-ok        = &Test::EXPORT::DEFAULT::cmp-ok;
constant &isa-ok        = &Test::EXPORT::DEFAULT::isa-ok;
constant &can-ok        = &Test::EXPORT::DEFAULT::can-ok;
constant &does-ok       = &Test::EXPORT::DEFAULT::does-ok;
constant &like          = &Test::EXPORT::DEFAULT::like;
constant &unlike        = &Test::EXPORT::DEFAULT::unlike;
constant &use-ok        = &Test::EXPORT::DEFAULT::use-ok;
constant &dies-ok       = &Test::EXPORT::DEFAULT::dies-ok;
constant &lives-ok      = &Test::EXPORT::DEFAULT::lives-ok;
constant &eval-dies-ok  = &Test::EXPORT::DEFAULT::eval-dies-ok;
constant &eval-lives-ok = &Test::EXPORT::DEFAULT::eval-lives-ok;
constant &throws-like   = &Test::EXPORT::DEFAULT::throws-like;
constant &fails-like    = &Test::EXPORT::DEFAULT::fails-like;
constant &todo          = &Test::EXPORT::DEFAULT::todo;
constant &skip          = &Test::EXPORT::DEFAULT::skip;
constant &pass          = &Test::EXPORT::DEFAULT::pass;
constant &flunk         = &Test::EXPORT::DEFAULT::flunk;

class TestBlock does Callable {
    has $.got;
    has $.desc;
    has Bool $!negated = False;

    method ok              { $.true }
    method not             { $!negated = not $!negated; self }
    method eq(Mu \exp)     { ($!negated ?? &isnt   !! &is  )( $!got, exp, $!desc ) }
    method like(Mu \exp)   { ($!negated ?? &unlike !! &like)( $!got, exp, $!desc ) }
    method true            { ($!negated ?? &nok    !! &ok  )( $!got,      $!desc ) }
    method approx          { !!! 'TODO' }
    method eqv(Mu \exp)    { if $!negated { ok($!got !=== exp, $!desc)
                                            or diag "expected: anything except {exp.raku}\n     got: $!got" }
                             else         { is-deeply $!got, exp, $!desc    }}
    method deeply(Mu \exp) { $.eqv(exp) }
    method cmp             { !!! 'TODO' }
}

use MONKEY-TYPING;
augment class Block {
    multi method is(&b:)             { TestBlock.new(:got(b),  :desc(&b.WHY))}
    multi method is(&b: Str() $s)    { TestBlock.new(:got(b),  :desc(&b.WHY)).eq($s)}
    multi method isn't(&b:)          { TestBlock.new(:got(b),  :desc(&b.WHY)).not}
    multi method isn't(&b: Str() $s) { TestBlock.new(:got(b),  :desc(&b.WHY)).not.eq($s)}}
