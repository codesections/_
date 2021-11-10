need Self::Recursion;

my %modules = ('Self::Recursion' => Recursion::EXPORT::DEFAULT::.pairs.Hash);

sub EXPORT(*@package-subset)  {
    die "TODO" when @package-subset ⊈ %modules.keys;
    %modules{@package-subset || *}».List.flat.Map
}
