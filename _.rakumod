need Self::Recursion;
constant &_ = &Self::Recursion::term:<&_>;
need Print::Dbg;
constant &dbg = &Print::Dbg::dbg;
need Pattern::Match;
constant &choose = &Pattern::Match::choose;
need Text::Paragraphs;
constant &paragraphs = &Text::Paragraphs::paragraphs;
need Text::Wrap;
constant &wrap-words = &Text::Wrap::wrap-words;

class X::Import::InvalidPos is X::Import::Positional {
    has %.exports;
    has $.invalid;
    method message {
        "Error while importing from '_':\n"
        ~ “Cannot import '$(+$.invalid == 1 ?? $.invalid !! "($.invald.join(", "))")' from _.\n”
        ~"_ exports:\n" ~@.exports.keys.join("\n").indent(4)
    }
}




multi EXPORT(*%n)  { ('&term:<&_>' => &Self::Recursion::term:<&_>, |OUR.kv).Map }
multi EXPORT(*@requested-symbols, *%n) {
    my %exports = (|OUR::.pairs, '&term:<&_>' => &_);
    my (@valid, @invalid);
    for @requested-symbols.map({ $_ eq '&_' ?? '&term:<&_>' !! $_}) -> $sym {
        if %exports{$sym}:p -> $_ { @valid.push:   $_   }
        else                      { @invalid.push: $sym }}
    when ?@invalid { die X::Import::InvalidPos.new: :%exports:@invalid}
    default        { @valid.Map }
}


    # when @package-subset ⊈ %modules.keys {
    #     die X::Import::InvalidPos.new: :source-package<_>:valid(%modules.keys)
    # }
    #%modules{@package-subset || *}».List.flat.Map

    # my @symbols = @wants.map(&add-matching-sigil);
    # my %exports is Set = |OUR::.keys, '&term:<&_>';
    # if @symbols.grep({not %exports{$_}}) -> $invalid {
    #     die X::Import::InvalidPos.new: :source-package<_>:%exports:$invalid }

    # say @symbols;
    # say OUR::.keys;
    # say  OUR::{@symbols}:kv;
    #(OUR::{@symbols}:kv).Map

# sub add-matching-sigil($_) {
#     when '&_'               { '&term:<&_>'}
#     for <& $ % @> -> $sigil { when OUR::{$sigil ~ $_} { $sigil ~ $_}}
#     default                 { $_ }}
# sub to-symbol-pair($_) {
#     when '&_'               { '&term:<&_>' => &Self::Recursion::term:<&_> }
#     for <& $ % @> -> $sigil { if OUR::{"$sigil$_"} -> \sym  { return "$sigil$_" => sym }}
#     default                 {
#         die X::Import::InvalidPos.new: :source-package<_>:exports(:TODO):invalid($_)
#     }}

# my %modules = ('Self::Recursion'  => Self::Recursion::EXPORT::DEFAULT::.pairs.Hash,
#                'Print::Dbg'       => Print::Dbg::EXPORT::DEFAULT::.pairs.Hash,
#                'Pattern::Match'   => Pattern::Match::EXPORT::DEFAULT::.pairs.Hash,
#                'Text::Wrap'       => Text::Wrap::EXPORT::DEFAULT::.pairs.Hash,
#                'Text::Paragraphs' => Text::Paragraphs::EXPORT::DEFAULT::.pairs.Hash);
