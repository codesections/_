need Pattern::Match;

my %export =  Match::EXPORT::DEFAULT::.pairs.Hash;

sub EXPORT is export { %export.Map }
