need Self::Recursion;

my %export =  Recursion::EXPORT::DEFAULT::.pairs.Hash;

sub EXPORT is export { %export.Map }
