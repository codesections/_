need Test;
unit module Test::Fluent;
# TODO: Finish and test {}.output.is.…
#       should .is(val) be legal?  Maybe with ~~ semantics?
#       consider accepting long params w/ $.approx (maybe via map?)
#       find different name for .is / .is.like.
#         - .is.equal?
#         - .is.match-for? .is.match.for?
#         - .is(* …)
#         - .is.same-as? .is.same.as?

OUR::{$_} := Test::EXPORT::DEFAULT::{$_} for <&plan &done-testing &subtest &diag &skip &bail-out &todo &skip-rest>;

use Test;
multi trait_mod:<is>(Routine $r, :$test) { trait_mod:<is>($r, :test-assertion) }
my role Testable {
    has &.b;
    multi method ok         is test { $.true }
    multi method deeply($_) is test { $.eqv: $_ }
    multi method auto-flunk is test { flunk  |$.msg }
    multi method auto-pass  is test { pass   |$.msg }
    method msg { &!b.WHY || ()} }

my class Tester {...}
my class NegatedTester does Testable  {
    multi method not { Tester.new: :&!b}

    # multi method approximately(|c)       is test { is-approx   &!b(), |c }
    # multi method approx(|c)              is test { is-approx   &!b(), |c }
    # multi method dead(:$like!, *%m)      is test { throws-like &!b,              $like,   |$.msg, |%m }
    multi method alive      is test { dies-ok  &!b,                  |$.msg  }
    # multi method alive    is test { lives-ok &!b,                  |$.msg }
    multi method dead       is test { lives-ok &!b,                  |$.msg  }
    # multi method dead     is test { dies-ok  &!b,                  |$.msg }
    multi method eq($exp)   is test { isnt     &!b(),          $exp, |$.msg  }
    # multi method eq($exp) is test { is       &!b(),          $exp,  |$.msg }
    multi method like($exp) is test { unlike   &!b(),          $exp, |$.msg  }
  # multi method like($exp) is test { like     &!b(),          $exp, |$.msg }
    multi method true       is test { nok      &!b(),                |$.msg  }
    # multi method true     is test { ok       &!b(),                |$.msg }
    multi method eqv($exp)  is test { cmp-ok   &!b(), &[!eqv], $exp, |$.msg }
    # multi method eqv(Mu $exp)            is test { is-deeply   &!b(),            $exp,    |$.msg }
}

my class Tester does Testable  {
    multi method not  { NegatedTester.new: :&!b}
    multi method type { self but role { method that(|c)  {
        self but role { multi method isa(Mu \exp)     is test { $.a: exp  }
                        multi method does(Mu \exp)    is test { does-ok &.b.(), exp,      |$.msg}
                        multi method can(Str \exp)    is test { can-ok  &.b.(), exp,      |$.msg}
                        multi method can(*%h where 1) is test { can-ok  &.b.(), %h.kv[0], |$.msg}}}} }

    multi method a                       is test { self }
    multi method a(Mu:U $exp)            is test { isa-ok      &!b(),            $exp,    |$.msg }
    multi method alive                   is test { lives-ok    &!b,                       |$.msg }
    multi method approximately(|c)       is test { is-approx   &!b(), |c }
    multi method approx(|c)              is test { is-approx   &!b(), |c }
    multi method dead                    is test { dies-ok     &!b,                       |$.msg }
    multi method dead(:$like!, *%m)      is test { throws-like &!b,              $like,   |$.msg, |%m }
    multi method eq( $exp)               is test { is          &!b(),            $exp,    |$.msg }
    multi method eqv(Mu $exp)            is test { is-deeply   &!b(),            $exp,    |$.msg }
    multi method failure(:$like!)        is test { fails-like  &!b,              $like,   |$.msg }
    multi method failure                 is test { isa-ok     (&!b() orelse $_), Failure, |$.msg }
    multi method like($exp)              is test { like        &!b(),            $exp,    |$.msg }
    # multi method like($exp, :$cmp-with!) is test { cmp-ok      &!b(), $cmp-with, $exp,    |$.msg }
    # multi method like($exp, :$with!)     is test { cmp-ok      &!b(), $with,     $exp,    |$.msg }
    multi method true                    is test { ok          &!b(),                     |$.msg }
    multi method usable                  is test { use-ok      &!b(),                     |$.msg }
}

use MONKEY-TYPING;
augment class Block {
    my class Printer { has $!txt handles <Str> = '';
                       method print(+a) { $!txt ~= a.join }}
    multi method is   (&b:)           { Tester.new: :&b }
    multi method is(&b: $exp, :$with) is test { cmp-ok &b(), $with, $exp, |(&b.WHY || ()) }
    multi method isn't(&b:)           { NegatedTester.new: :&b }
    multi method output(&b: Bool :$stdout=False, Bool :$stderr=False)         {
        { temp $*OUT = my $out = ($stdout || none($stdout, $stderr)) ?? Printer.new !! '';
          temp $*ERR = my $err = ($stderr || none($stdout, $stderr)) ?? Printer.new !! '';
          b();
          $out ~ $err}.&{.set_why(&b.WHY); $_}}
}


            # say $n;
            # #my &cf = nextcallee;
            # note 'enter';
            # say Backtrace.new.full;
            # say my $callframe = callwith($n++);
            # while $callframe.file ne $?FILE | $calling-file { say $callframe = callwith($n++)}

            # while $callframe.file ne $calling-file {
            #     note "\n======";
            #     say $callframe.file;
            #     say $calling-file;
            #     say $callframe.file eq $calling-file;
            #     say $callframe = callwith($n++)}
            # note '++++++++++++++++?=================================?';

# multi sub trait_mod:<is>(Routine $s, :$hidden-from-tests) {
# note "????????????";
# my $wh = $s.add_phaser('ENTER ', {
#  note 'ENTER =======================';
#                               &callframe.wrap: {

#             state $first = True;
#             do if $first { $first = False andthen $calling-frame } // callsame }});

# note "????????????--3";
# $s.add_phaser('LEAVE', { say 5;
#                           &callframe.unwrap($wh)});

# }

# my role Testable[:$negated!] does Testable  {

#     multi method eq(&b: $_)      is test { isnt( b, $_,    |$.msg) }
#     multi method true(&b:)       is test { nok( b,         |$.msg) }
#     multi method auto-pass(&b:)  is test { flunk(          |$.msg) }
#     multi method auto-flunk(&b:) is test { pass(           |$.msg) }
#     multi method like(&b: $_)    is test { unlike(  b, $_, |$.msg) }
#     multi method alive(&b:)      is test { dies-ok( &b,    |$.msg) }
#     multi method dead(&b:)       is test { lives-ok(&b,    |$.msg) }
#     multi method eqv(&b: $_)     is test { my $got = b();
#         diag "expected: anything except $_.raku()\n     got: $got" unless ok($got !=== $_, &.msg)}
#     multi method not { self.^parents.head but Testable[:non-negated] }
# }
# my role Testable[:$non-negated!] does Testable  {
#     multi method not { self.^parents.head  but Testable[:negated] }
#     multi method type { self but role { method that(|c) { $.type-that(|c)}} }

#     multi method a                 is test { self }
#     multi method auto-pass         is test { pass                   |$.msg }
#     multi method auto-flunk        is test { flunk                  |$.msg }
#     multi method a(&b: Mu:U \type) is test { isa-ok       b, type,  |$.msg}
#     multi method usable(&b:)       is test { use-ok       b,        |$.msg}
#     multi method approximately(|c) is test { $.approx:    |c }
#     multi method eq(&b: $_)        is test { is           b, $_,    |$.msg }
#     multi method true(&b:)         is test { ok           b,        |$.msg }
#     multi method like(&b: $_)      is test { like         b, $_,    |$.msg }
#     multi method alive(&b:)        is test { lives-ok    &b,        |$.msg }
#     multi method dead(&b:)         is test { dies-ok     &b,        |$.msg }
#     multi method dead(&b: :$like!,
#                       *%matcher)   is test { throws-like &b, $like, |$.msg, |%matcher }

#     multi method like(&b: $_, :cmp-with(:$with)!) is test { cmp-ok b, $with, $_, |$.msg }
#     multi method eqv(&b: Mu $_ )                  is test { is-deeply b, $_, |$.msg }
#     multi method failure(&b: :$like!)             is test { fails-like &b, $like, |$.msg }
#     multi method failure(&b:)                     is test { isa-ok my $f = b, Failure, |$.msg;
#                                                             $f.handled = True }

#     multi method approx(&b: $_, :relative-tolerance(:$rel-tol), :absolute-tolerance(:$abs-tol)) is test {
#         is-approx b, $_, $.msg, |(:$rel-tol with $rel-tol), |(:$abs-tol with $abs-tol) }

#     method type-that(&b:) {
#         self but role { multi method isa(&b: Mu \exp)     is test { $.a: exp  }
#                         multi method does(&b: Mu \exp)    is test { does-ok b, exp,      |$.msg}
#                         multi method can(&b: Str \exp)    is test { can-ok  b, exp,      |$.msg}
#                         multi method can(&b: *%h where 1) is test { can-ok  b, %h.kv[0], |$.msg}}}
# }

# #multi sub postfix:<is>(&b) is export { &b but Testable[:non-negated]}
# #multi sub postfix:<?>(|) is export { }
# multi sub is(&got, &expected) is export { expected Tester.new: :&got }
# sub Is(&got) is export { Tester.new: :&got }
# #sub Is(\got) is export { {got} but Testable[:non-negated]}

    #multi method failure(:(:$_=&!b())) is test { isa-ok $_, Failure, |$.msg; .handled = True;}
    #multi method failure               is test { isa-ok &!b().&{.handled = True; $_}, Failure, |$.msg}
    #multi method failure               is test { isa-ok &!b().&{$_// $_}, Failure, |$.msg}
  # multi method eqv($_)    is test { my $got = &!b();
  #     diag "expected: anything except $_.raku()\n     got: $got" unless ok($got !=== $_, &.msg)}
    # multi method eqv($exp)    is test {
    #     given &!b() { when $exp { diag "expected: anything except $exp.raku()\n     got: $_" }
    #                   default   { ok($_ !=== $exp, &.msg)}}}

    # multi method approx($_, :relative-tolerance(:$rel-tol), :absolute-tolerance(:$abs-tol)) is test {
    #     is-approx &!b(), $_, $.msg, |(:$rel-tol with $rel-tol), |(:$abs-tol with $abs-tol) }

    # multi method eqv($exp)  is test { &!b().&{ ok($_ !eqv $exp, |$.msg)
    #                                              or diag "expected: {$exp.raku} !eqv {.raku}" }}
