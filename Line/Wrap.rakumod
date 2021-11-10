sub line-wrap(Str $text, :$max = 80, :$indent = "" --> Str:D) {
        my @lines = [''];
        my Int $width = $indent.chars;

        for $text.words { if $width + .chars >= $max {
                                @lines.push: $indent ~ $_;
                                $width = $indent.chars }
                          else { $width += .chars;
                                 @lines.tail ~= " $_" } }
        @lines.join("\n").trim;
    }
