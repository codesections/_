use Test;
unit module Markdown;

my token doctest-comment { '<!--' <.ws> 'doctest' <(.+?)> '-->' \n {$*line-number++}}
my token any-line        { \N*? \n {say $/; dd :$*line-number; $*line-number++} }
my token start-token { ['`' | '~'] ** 3..*}
my token info-string { 'raku' \N* \n {$*line-number++}}

sub doctest(IO::Path $file) {

    my $pos = 0;
    with $file.slurp {
        my $*line-number = 1;
        while $pos < .chars {

            my Str() $codeblock = '' R// m:c($pos)• <any-line>*?
                                                    <doctest-comment>
                                                <start-token>  <.ws> <info-string>
                                                <( <any-line>*? )> {}
                                                $( $<start-token>)
                                                •;
        $pos = $/.to // last;
        my %cfg = $<doctest-comment>.EVAL;


        my ($msg, $output);
        do { $output = ( $codeblock ~~ m:g • '# OUTPUT: «' <(.+?)> '»' •);
             temp $*OUT =  $msg = new(
                 class { has $!txt handles <Str>;
                         method print(+a) { $!txt ~= a.join }}:);
             ('' R// %cfg<hidden> ~$codeblock).EVAL;
        }
        my $expected = $output.map({"'$_'"}).join(' .* ');
        $msg.&like: / <$expected> /, "Output matches example $(++$) from $file.basename()"
          or diag "<\$expected> regex was: $expected\nfrom line $*line-number";
    }}

}

doctest('./Self/README.md'.IO);
