need Self::Recursion;
need Print::Dbg;
need Pattern::Match;
need Text::Paragraphs;
need Text::Wrap;
need Test::Fluent;
need Test::Doctest::Markdown;

my constant &_ = &Self::Recursion::term:<&_>;


my constant @default-export-pairs = ('&term:<&_>'  => &Self::Recursion::term:<&_>,
                                     '&dbg'        => &Print::Dbg::dbg,
                                     '&choose'     => &Pattern::Match::choose,
                                     '&paragraphs' => &Text::Paragraphs::paragraphs,
                                     '&wrap-words' => &Text::Wrap::wrap-words);

my constant @test-fluent-exports = <&plan &done-testing &subtest &diag &skip-rest &bail-out>;
my constant @test-doctest-exports = <&doctest>;

package EXPORT::DEFAULT { OUR::{.key} := .value                      for @default-export-pairs }
package EXPORT::Test    { OUR::{$_} := Test::Fluent::{$_}            for @test-fluent-exports;
                          #OUR::{.key} := .value                      for Test::Fluent::EXPORT::DEFAULT::.pairs;
                          OUR::{$_} := Test::Doctest::Markdown::{$_} for @test-doctest-exports; }
package EXPORT::ALL     { OUR::{.key} := .value                      for @default-export-pairs;
                          OUR::{$_} := Test::Doctest::Markdown::{$_} for @test-doctest-exports;
                          OUR::{$_} := Test::Fluent::{$_}            for @test-fluent-exports}

class X::Import::InvalidPos is X::Import::Positional {
    has %.exports;  has $.invalid;
    method message {
        "Error while importing from '_':\n"
        ~ “Cannot import '$(+$.invalid == 1 ?? $.invalid !! "($.invald.join(", "))")' from _.\n”
        ~"_ exports:\n" ~%.exports.keys.join("\n").indent(4) }
}

proto EXPORT(|) {*}
multi EXPORT { %().Map}
multi EXPORT(*@requested-symbols where * > 0, *%n) {
    my %exports = (|OUR::EXPORT::ALL::.pairs, '&term:<&_>' => &_);
    my (@valid, @invalid);
    for @requested-symbols.map({ $_ eq '&_' ?? '&term:<&_>' !! $_}) -> $sym {
        if %exports{$sym}:p -> $_ { @valid.push:   $_   }
        else                      { @invalid.push: $sym }}
    when ?@invalid { die X::Import::InvalidPos.new: :%exports:@invalid}
    default        { @valid.Map }
}
