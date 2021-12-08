need Self::Recursion;
need Print::Dbg;
need Text::Wrap;
need Text::Paragraphs;
need Pattern::Match;

class X::Import::InvalidPos is X::Import::Positional {
    has @.valid;
    method message {
        "Error while importing from '$.source-package':\n"
        ~ "The positional argument(s) in the 'use' statement were not valid.\n"
        ~"Valid positional arguments are:\n" ~$.valid.join("\n").indent(4)
    }
}

my %modules = ('Self::Recursion'  => Recursion::EXPORT::DEFAULT::.pairs.Hash,
               'Print::Dbg'       => Dbg::EXPORT::DEFAULT::.pairs.Hash,
               'Text::Wrap'       => Wrap::EXPORT::DEFAULT::.pairs.Hash,
               'Text::Paragraphs' => Paragraphs::EXPORT::DEFAULT::.pairs.Hash,
               'Pattern::Match'   => Match::EXPORT::DEFAULT::.pairs.Hash,
              );

sub EXPORT(*@package-subset)  {
    when @package-subset ⊈ %modules.keys {
        die X::Import::InvalidPos.new: :source-package<_>:valid(%modules.keys)
    }
    %modules{@package-subset || *}».List.flat.Map
}
