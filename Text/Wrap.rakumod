unit module Wrap;

role WrapMode {}; class KeepParagraphs does WrapMode {};
                  class KeepNewlines   does WrapMode {};
                  class ReflowAll      does WrapMode {};

multi paragraphs(Str $s, WrapMode :mode($_) = KeepParagraphs, Bool :$chomp = True) {
    my $rx:<¶> = rx• || $<until-bullet-end>=[ ^^  $<chomp>=[ \s* @(<- + *>) \N*]  \n      ]
                     || $<until-blank-line>=[     $<chomp>=[ .+? ]                \n\s*\n ]
                     || $<until-end-of-txt>=[     $<chomp>=[ .+  ]                $       ] •;

    when KeepParagraphs { gather while $s ~~ m:c• $rx:<¶> • { take($chomp ?? ~$<chomp> !! ~$/) }}
    when KeepNewlines   { $s.trim-leading.lines :$chomp }
    when ReflowAll      { $s.trans("\n" => "\n", :s).lines(:$chomp)».trim-leading.join }
}

sub wrap-paragraph(Str $_, :$max-len, :prefix($supplied-prefix)) {
    rx• ^ $<prefix>=[ \s* ]    $<body>=[ .*? ]    $<postfix>=[ \s* ] $ •;

    my (&len, $prefix) = (&display-length, $supplied-prefix || ~$<prefix>);
    my $line-len = len $prefix;

    sub wrap-words-to-lines(@lines, $text ($word, $ws='')) {
        my @next-lines = gather if $line-len+len($word) ≤ $max-len {
                                       $line-len += len $word~$ws;
                                       take "@lines.tail()$word$ws" }
                                else { $line-len = len $prefix~$word~$ws;
                                       take @lines.tail.trim-trailing;
                                       take "$prefix$word$ws" }
        [ |@lines.head(*-1), |@next-lines ] };

    my @words =  $<body>.trans("\n" => ' ', :s).comb(/\S+|\s+/).batch(2);
    $prefix ~([''], |@words).reduce(&wrap-words-to-lines).join("\n") ~ $<postfix>
}

multi wrap-words( Str $_, Int :length($max-len)=80, Int :$indent=0, Str :$prefix=' 'x $indent,
                  |modes (Bool :$keep-paragraphs=False, Bool :$reflow-all=False, Bool :$keep-newlines=False)
                  --> Str:D) is export {
    PRE { only_one_mode_allowed:               $keep-newlines + $keep-paragraphs + $reflow-all ≤ 1 }
    PRE { cannot_set_both_indent_and_prefix:   $indent == 0 or ' 'x $indent eq $prefix             }
    my WrapMode $mode = do with modes.hash.head.key // <KeepParagraphs> { ::(.split('-')».tc.join) }
    .trim-leading.&paragraphs(:$mode, :!chomp).map(*.&wrap-paragraph(:$max-len:$prefix)).join
}

#| Estimates a Str's display width.  This is in theory impossible (it depends on the font) but in practice
#| it typically works (most fonts behave reasonably).  See https://stackoverflow.com/questions/3634627
#| Note: Raku removes many 0-width codepoints for us by combining them during the NFC normalization
sub display-length($_) is pure {
   sum .comb.map: { when 0x1160 ≤ .ord ≤ 0x11FF                { 0 } # Hangul Jamo medial vowels
                    when .uniprop('EastAsianWidth') eq 'W'|'F' { 2 }
                    default                                    { 1 }}}
