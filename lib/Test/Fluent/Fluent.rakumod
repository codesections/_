unit module Test::Fluent;
use Test;

OUR::{$_} := ::{$_} for <&plan &done-testing &subtest &diag &skip &bail-out &todo &skip-rest>;

# sub can-ok (|)   {}
# sub cmp-ok (|)   {}
# sub dies-ok (|)   {}
# sub does-ok (|)   {}
# sub flunk (|)   {}
# sub is-approx (|)   {}
# sub like (|)   {}
# sub isa-ok (|)   {}
# sub lives-ok (|)   {}
# sub use-ok (|)   {}
# sub ok (|)   {}
# sub nok (|)   {}
# sub pass (|)   {}
# sub unlike (|)   {}


my class Tester {

#use Test;
    multi trait_mod:<is>(Routine $r, :$test) {} #{ trait_mod:<is>($r, :test-assertion) }
    has      &.block is required;
    has Bool:D $.negated=False;
    has      @.chain;
    has Mu   $.value handles <gist raku Str> = do given try {no fatal; &!block()} { when ?$! { $! }
                                                                                    default  {.so; $_ }};

    multi method msg($exp?) {

        if &!block.WHY -> $_ { ~$_ }
        else { "Test that: \{\$GOT}.is." ~@!chain.join(".") ~ "(\$EXPECTED)" with $exp;}
    }

    multi method a($exp)          is test { $.has.a.class: $exp}
    multi method alive            is test { ($!negated ?? &dies-ok !! &lives-ok)(&!block,       |$.msg); self }
    multi method like(Regex $exp) is test { ($!negated ?? &unlike  !! &like    )($.value, $exp, |$.msg); self }
    multi method like($exp)       is test { $.is."~~"($exp) }
    multi method true             is test { ($!negated ?? &nok     !! &ok      )($.value,       |$.msg); self }
    multi method dead             is test { $.not.alive.not; self }

    multi method a                 is test { self          }
    multi method map(&fn)          is test { (my &block = {fn($!value)}).set_why(&!block.WHY);
                                             $.clone: :&block, :value(block) }
    multi method ok                is test { $.true        ; self}
    multi method deeply($_)        is test { $.eqv:    $_  ; self} # TODO
    multi method approximately(|c) is test { $.approx: |c  ; self} # TODO
    multi method auto-flunk        is test { flunk  |$.msg ; self}
    multi method auto-pass         is test { pass   |$.msg ; self}

    multi method approx(|c)        is test { is-approx   $!value, |c, |$.msg; self }      # TODO negate
    multi method usable            is test { use-ok      $!value,           |$.msg; self} # TODO negate

    multi method class($_)   is test { my $exp = ($_ ~~ Str:D ?? ::($_) !! $_);
                                       if ($exp, $!value) ~~ (Exception, Failure) { $!value .= exception }
                                       $!negated ?? $.and."~~"($exp)  !! isa-ok  $.value, $exp, |$.msg; self }
    multi method role($_) is test { my $exp = ($_ ~~ Str:D ?? ::($_) !! $_);
                                    $!negated ?? $.is."~~"($exp) !! does-ok $.value, $exp, |$.msg; self}
    multi method method(Str $exp) is test { $!negated ?? $.map(*.^can($exp)).true !! can-ok  $.value, $exp, |$.msg; self}
    multi method attribute(Str $exp) is test { $.map(*.^attributes.grep(*.has_accessor).grep(/$exp$/).so).true ; self}
 BEGIN {
    for <not lacking without lacks doesn't> -> $name {
        Tester.^add_method($name, (method () is test { $.clone: :negated(not $.negated)}).set_name($name))}

    for [ &[eq], &[!eq]; &[ne], &[!ne]; &[before], &[!before]; &[after], &[!after]; &[gt], &[!gt]; &[ge], &[!ge];
          &[lt], &[!lt]; &[le], &[!le]; &[eqv], &[!eqv]; &[==], &[!==]; &[≠], &[!≠]; &[<], &[!<]; &[<=], &[!<=];
          &[>], &[!>]; &[>=], &[!>=]; &[===], &[!===]; &[=:=], &[!=:=]; &[=~=], &[!=~=]; &[~~], &[!~~]; &[∈], &[!∈];
          &[∉], &[!∉]; &[≡], &[!≡]; &[≢], &[!≢]; &[∋], &[!∋]; &[∌], &[!∌]; &[⊂], &[!⊂]; &[⊄], &[!⊄]; &[⊆], &[!⊆];
          &[⊈], &[!⊈]; &[⊃], &[!⊃]; &[⊅], &[!⊅]; &[⊇], &[!⊇]; &[⊉], &[!⊉]
        ] -> $ (&reg, &neg)  {
        my $name = S['infix:'['<'|'«'] (.*) ['»'|'>']] = $0 with &reg.name;
        my \op  = method ($_) is test { @!chain.push("\"$name\"");
                                        cmp-ok $.value, [&reg, &neg][$.negated], $_, |$.msg($_); self}.set_name: $name;
        my \rev = method ($_) is test { @!chain.push("\"!$name\"");
                                        cmp-ok $.value, [&neg, &reg][$.negated], $_, |$.msg($_); self}.set_name: "!$name";
        Tester.&{.^add_method: $name, op; .^add_method: "!$name", rev }
    }
    Tester.^add_method($_, method {@!chain.push($_); self}.set_name($_)) for <an and is object obj type that has>;

    submethod TWEAK(|) { for self.^methods(:local) -> $m {
        $m.?wrap(-> | { unless $m.name eq <negated TWEAK BUILDALL raku gist Str msg value>.any {
                              @!chain.push: $m.name; };
                        callsame }) }}
    Block.^add_method($_, method {Tester.new: :block(self)}.set_name($_)) for <is has>;
    Block.^add_method($_, method {$.is.not                }.set_name($_)) for <lacks isn't>;
    Block.^add_method($_, method {... 'NYY'               }.set_name($_)) for <output>;
}
}
#----------------



# TODO: Finish and test {}.output.is.…
#       should .is(val) be legal?  Maybe with ~~ semantics?
#       better default msgs?
#       consider accepting long params w/ $.approx (maybe via map?)
#       does {'s' + 1}.is.not.dead: :like(X::AdHoc) even make sense?
#         ^^^ maybe cut it and chain so we can do {'s' + 1}.is.dead.and.not.eqv
#       find different name for .is / .is.like. #         - .is.equal? #         - .is.match-for? .is.match.for?
                                                #         - .is(* …)   #         - .is.same-as? .is.same.as?


    # submethod new(&b) {
    #     for self.^methods(:local) -> $m { $m.?wrap(-> | {unless $m.name eq 'BUILDALL'|'raku' {#`[TODO]}; callsame }) }
    #     self.bless: :block(&b);
    # }
#sub attest(&block) is export { Tester.new: :&block }


# my role TestErrFmt[:$got, :$op, :$exp] {
#     method say($_) { .chars ≤ 80 && .trim.starts-with('# exp') ?? callwith("# comparison failed: $got $op {$exp.raku}")
#                                                                !! callsame }}
                # my \op  = method ($exp)  {
                #     &Test::failure_output() = $PROCESS::ERR but TestErrFmt[:got($.value.raku), :op($name), :$exp] ;
                #     cmp-ok $.value, [&reg, &neg][$.negated], $exp, |$.msg;
                #     &Test::failure_output() = $PROCESS::ERR;
                #     self
                # }.set_name: $name;

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

    # multi method eqv($exp)  is test { [&{is-deeply                     &!b(), $exp, |$.msg },
    #                                    &{cmp-ok             &!b(),   &[!eqv], $exp, |$.msg }][$!negated]}

    # # multi method eqv($exp, 0 :$!=$.negated)  is test { is-deeply &!b(),            $exp,    |$.msg }
    # # multi method eqv($exp, 1 :$!=$.negated)  is test { cmp-ok    &!b(),   &[!eqv], $exp,    |$.msg }
    # multi method eqv($exp) is test { when $!negated.so  { cmp-ok     &!b(),   &[!eqv], $exp,    |$.msg }
    #                                  when $!negated.not { is-deeply  &!b(),            $exp,    |$.msg }}

    # multi method dead(
    #      :like($exp)!, *%m)   is test { (&!block,   $exp, |$.msg).&{ [&neqv, {throws-like |@_, %m}][$!negated](|$_) }; self }

    #multi method an                is test { self          }
    #multi method and               is test { self          }
    #multi method is                is test { self          }

    #multi method eqv($exp)    is test { ($.value, $exp, |$.msg).&{ [&is-deeply,   &neqv][$!negated](|$_) }; self }


    # multi method type(:($t=self)) { self but role { method that(|c)  {
    #     self but role { multi method isa(Mu \exp)  is test { $.a: exp;                     $t }
    #                     multi method does(Mu \exp) is test { does-ok $.value, exp, |$.msg; $t }
    #                     multi method can(Str \exp) is test { can-ok  $.value, exp, |$.msg; $t }}}}}

    #`{ if ($exp, $!value) ~~ (Exception, Failure) { $!value .= exception }
                                        $!negated ?? $.and."~~"($exp)  !! isa-ok  $.value, $exp, |$.msg; self}

    # my class Printer { has $!txt handles <Str> = '';
    #                    method print(+a) { $!txt ~= a.join }}
    # multi method output(&block: Bool :$stdout=False, Bool :$stderr=False)         {
    #     { temp $*OUT = my $out = ($stdout || none($stdout, $stderr)) ?? Printer.new !! '';
    #       temp $*ERR = my $err = ($stderr || none($stdout, $stderr)) ?? Printer.new !! '';
    #       block();
    #       $out ~ $err}.&{.set_why(&block.WHY); $_}}

# role Testable {
    #multi method is(&block:) { Tester.new: :&block }
    #multi method ::('has')         { $.is }
    #multi method lacks       { $.is.not }
    #multi method isn't       { $.is.not }
    #multi method output(|)   {... 'NYI'}
# }

    # for <an and is object obj type that has> -> $name {
    #     Tester.^add_method($name, (method () is test {                          ; self }).set_name($name))}

            # for ((<is has>, method {Tester.new: :block(self)}), (<lacks isn't>, method {$.is.not}),
            #      ((<output>,), method {...})) -> $ (@names, &m) {
            #     Block.^add_method($_, &m.set_name($_)) for @names} }
