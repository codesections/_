unit module Text::Paragraphs;

my token bullet        { [@(<- + *>) | [ \d\d? '.' ]] \s*  }
my token non-bullet    { <-[- + *] - [\d]> }
my token bullet-prefix { ^^ $<ws>=(\h*) <bullet> }
my token indent-prefix { ^^        \h* }
my token blank-line    { ^^        \h* [\n | $ ] }
my token rest-of-line  {           \N* [\n | $ ] }
my token continuation-line($indent) { \h ** {$indent} [\S & <non-bullet>] <rest-of-line> }

our proto paragraphs(|) is export {*}

multi paragraphs(Str $_, :$chomp=True, :$limit is copy =∞, :(:$pos is copy = 0) --> Seq()) {
    gather until $pos ≥ .chars or $limit-- ≤ 0 {
        if    m:p($pos)• <bullet-prefix> • { my $indent = .<ws>.chars..$_.chars with $<bullet-prefix>;
                                             m:p($pos)• <bullet-prefix> <rest-of-line>
                                                        <continuation-line($indent)>*  • }
        elsif m:p($pos)• <indent-prefix> • { my $indent = $<indent-prefix>.chars;
                                             m:p($pos)• <indent-prefix> <( <rest-of-line>
                                                        <continuation-line(0..^$indent)>*
                                                        <blank-line>*                  )> • }
        $chomp ?? take(~$/.trim-trailing) !! take(~$/) andthen $pos = $/.to }
}

multi paragraphs(Cool       $c, :$chomp=True, :$limit=∞) { $c.Str.&paragraphs: :$chomp:$limit }
multi paragraphs(IO::Path   $p, :$chomp=True, :$limit=∞, :$enc = 'utf8', :$nl-in = ["\x0A", "\r\n"]) {
    my $handle = $p.open(:$enc:$nl-in) andthen LEAVE try .close;
    eager $handle.&paragraphs: :$chomp:$limit }
multi paragraphs(IO::Handle $h, :$chomp=True, :$limit is copy =∞, :$close) {
    flat gather for $h.comb(/.*? [\n <blank-line> | $]/, :$close) {
        for .&paragraphs: :$chomp:$limit { $limit--; .take }
        last if $limit ≤ 0}
}
