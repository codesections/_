unit module Test::Fluent;
use Test;

# TODO: - Extract Tester.actual from a block if we get one in Tester.new (& save any Failure/Ex.)
#       - Set Tester.description based on &block.WHY (if any)
#       - Use other Test fns (&is, &is-deeply, &fails-like) when they'd give better msgs that &cmp-ok
#       - Wrap Tester.actual in a block where needed for &dies-ok, etc.
#       - Add methods (maybe via metaprogramming -- see old.rakumod) for other comparisons (.isa, .^can, .does, etc)
#       - Wrap &done-testing (and maybe &plan?) to get rid of &run-tests
#       - add *far* more tests (esp. of correctly _failing_ tests)

OUR::{$_} := ::{$_} for <&plan &done-testing &subtest &diag &skip &bail-out &todo &skip-rest>;

my class UnsetValue {}
class Tester {...}
class TestRunner { has @!tests;
    multi method add-test(Tester:D $t) { @!tests.push($t) andthen $t }
    multi method run-all() { for @!tests { .expected =:= UnsetValue ?? die('-- no ?') !! .run }}}

my $tr = TestRunner.new;
multi run-tests is export { $tr.run-all}

class Tester { has Mu  $.expected  = UnsetValue;
               has Mu  $.actual    is required;
               has     &.comparator = &die.assuming('No comparator set');
               has Str $.description;
    multi method run                    { cmp-ok $!actual, &!comparator, $!expected, |$.msg }
    multi method expect(Mu $!expected)  { self }
    multi method cmp-with(&!comparator) { self }
    method Bool(|) { # *a hack*: .Bool is called from &prefix:<!> as part of the execution of &[!~~].
        # See /src/Perl6/Actions.nqp line 7,458. Because &[!~~] is currently a compiler built-in, this seems to be the
        # only way to detect that we're being called from it rather than &[~~].  So, we use this to negate &[~~] as needed
        &!comparator = &[!~~] if (callframe(1).code, &!comparator)».name «eq» ('prefix:<!>', 'infix:<~~>');
        0 }
    submethod new($actual) { $tr.add-test: self.bless: :$actual }
    multi method msg       { with $!description       { $_ }
                             orwith &!comparator.name { m/'infix:' . (.*) .$/;
                                                        "Is $!actual.raku() {$0 // $_ } $!expected.raku() ?" }}
}

for [ &[eq], &[!eq], &[ne], &[!ne], &[before], &[!before], &[after], &[!after], &[gt], &[!gt], &[ge], &[!ge],
      &[lt], &[!lt], &[le], &[!le], &[eqv], &[!eqv], &[==], &[!==], &[≠], &[!≠], &[<], &[!<], &[<=], &[!<=],
      &[>], &[!>], &[>=], &[!>=], &[===], &[!===], &[=:=], &[!=:=], &[=~=], &[!=~=],  &[∈], &[!∈],
      &[∉], &[!∉], &[≡], &[!≡], &[≢], &[!≢], &[∋], &[!∋], &[∌], &[!∌], &[⊂], &[!⊂], &[⊄], &[!⊄], &[⊆], &[!⊆],
      &[⊈], &[!⊈], &[⊃], &[!⊃], &[⊅], &[!⊅], &[⊇], &[!⊇], &[⊉], &[!⊉],] -> &fn  {
    # We shadow ops instead of .wrap'ing them to avoid "unused is Sink contex" warnings.  This handles all binary ops
    # *except* for &[~~] and &[!~~] – those are compiler built-ins and need trickery with ACCEPTS and &prefix:<!>
    sub f (Mu \lhs, Mu \rhs, |c) { lhs ~~ Tester ?? lhs.cmp-with(&fn).expect(rhs) !! fn(lhs, rhs, |c) }
    &f.set_name(&fn.name.uc);
    OUR::EXPORT::DEFAULT::{"\&&fn.name()"} := &f }

our proto prefix:<Is>(|) is tighter(&postfix:<i>) is export  {*}
multi prefix:<Is>(Mu \value) { Tester.new: value}

our proto postfix:<?>(|)  is export {*}
multi postfix:<?>(Mu \exp) { # This is for &[~~]: since we can't wrap it, we make sure every RHS has an .ACCEPTS method
    # that calls .cmp-with. Some RHS are :U roles (eg, `Is 5 ~~ Stringy?`) which don't accept mixins - thus the FakeRole
    if exp.HOW.^can('pun') { unless exp.HOW ~~ Metamodel::ParametricRoleGroupHOW { say "ParametricRoleGroupHOW: " ~exp.HOW }
        my class FakeRole { has $.inner handles *;
            multi method ACCEPTS(Tester:D $t) { $t.cmp-with(&[~~]).expect($.inner)}}.new: :inner(exp) }
    else { exp but role { only method ACCEPTS(Tester:D $t --> Tester:D) { $t.cmp-with(&[~~]).expect(exp)}}}
}
