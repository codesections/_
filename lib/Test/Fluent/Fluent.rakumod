unit module Test::Fluent;
need Test;
# Re-exported in _.rakumod
constant &plan          = &Test::EXPORT::DEFAULT::plan;
constant &done-testing  = &Test::EXPORT::DEFAULT::done-testing;
constant &subtest       = &Test::EXPORT::DEFAULT::subtest;
constant &diag          = &Test::EXPORT::DEFAULT::diag;
constant &skip-rest     = &Test::EXPORT::DEFAULT::skip-rest;
constant &bail-out      = &Test::EXPORT::DEFAULT::bail-out;

# Just for local convenience
my constant &ok            = &Test::EXPORT::DEFAULT::ok;
my constant &nok           = &Test::EXPORT::DEFAULT::nok;
my constant &is            = &Test::EXPORT::DEFAULT::is;
my constant &isnt          = &Test::EXPORT::DEFAULT::isnt;
my constant &is-deeply     = &Test::EXPORT::DEFAULT::is-deeply;
my constant &like          = &Test::EXPORT::DEFAULT::like;
my constant &unlike        = &Test::EXPORT::DEFAULT::unlike;
# TODO vvv
my constant &is-approx     = &Test::EXPORT::DEFAULT::is-approx;
my constant &cmp-ok        = &Test::EXPORT::DEFAULT::cmp-ok;
my constant &isa-ok        = &Test::EXPORT::DEFAULT::isa-ok;
my constant &can-ok        = &Test::EXPORT::DEFAULT::can-ok;
my constant &does-ok       = &Test::EXPORT::DEFAULT::does-ok;
my constant &use-ok        = &Test::EXPORT::DEFAULT::use-ok;
my constant &dies-ok       = &Test::EXPORT::DEFAULT::dies-ok;
my constant &lives-ok      = &Test::EXPORT::DEFAULT::lives-ok;
my constant &eval-dies-ok  = &Test::EXPORT::DEFAULT::eval-dies-ok;
my constant &eval-lives-ok = &Test::EXPORT::DEFAULT::eval-lives-ok;
my constant &throws-like   = &Test::EXPORT::DEFAULT::throws-like;
my constant &fails-like    = &Test::EXPORT::DEFAULT::fails-like;
my constant &todo          = &Test::EXPORT::DEFAULT::todo;
my constant &skip          = &Test::EXPORT::DEFAULT::skip;
my constant &pass          = &Test::EXPORT::DEFAULT::pass;
my constant &flunk         = &Test::EXPORT::DEFAULT::flunk;

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
