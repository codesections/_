unit module Wrap;
sub line-wrap(Str $text, :$max = 80, :$indent = "" --> Str:D) is export {
        my @lines = [''];
        my Int $width = $indent.chars;

        for $text.trim.words -> $_ is copy {
            if $width + .chars >= $max { @lines.push: $indent ~ $_;
                                         $width = $indent.chars + .chars}
             else                      { $width += .chars + 1;
                                         @lines.tail ~= " $_" }}
        @lines.join("\n").trim
    }
