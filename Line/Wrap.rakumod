unit module Wrap;

sub line-wrap(Str $text, :$max = 80, :$prefix = '' --> Str:D) is export {
    my @lines = $prefix;
    for $text.comb(/\s+|\S+/) {
        if @lines[*-1].chars + .chars > $max { @lines.push: ~(S[^\s+ (.*)] = $0)}
        else                                 { @lines[*-1] ~= $_}  }
    @lines».trim-trailing.join: "\n$prefix"
}
