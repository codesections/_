unit module Test::Doctest::Markdown;
use Test;

my token doctest-comment { '<!--' <.ws> 'doctest' <(.+?)> '-->' \n {$*line-number++}}
my token any-line        { \N*? \n { $*line-number++} }
my token start-token { ['`' | '~'] ** 3..*}
my token info-string { 'raku' \N* \n {$*line-number++}}

our proto doctest(|)  {*}
multi doctest(IO::Path $file) { doctest($file.slurp, :file-name($file.basename))}

multi doctest(Str $_, :$file-name = '<anon>') {
    my ($pos, $ex-num) = (0, 1);
    my $*line-number = 1;
    while $pos < .chars {
        my Str() $codeblock = '' R// m:c($pos)• <any-line>*?
                                                <doctest-comment>?
                                            <start-token>  <.ws> <info-string>
                                            <( <any-line>*? )> {}
                                            $( $<start-token>)
                                            •;
        $pos = $/.to // last;
        my %cfg = do if $<doctest-comment> -> $_ { note 8; .EVAL } else { :hidden('')}

        my ($msg, $output);
        do { $output = ( $codeblock ~~ m:g • '# OUTPUT: «' <(.+?)> '»' •);
             temp $*OUT =  $msg = new(
                 class { has $!txt handles <Str> = '';
                         method print(+a) { $!txt ~= a.join }}:);
             ('' R// %cfg<hidden> ~$codeblock).EVAL;
        }
        my $expected = $output.map({"'$_'"}).join(' .* ');
        if $expected { $msg.&like: / <$expected> /, "Output matches code block $($ex-num++) from $file-name"
                              or diag "<\$expected> regex was: $expected\nfrom line $*line-number" }
        else { pass "No exceptions thrown in code block $($ex-num++) in $file-name"}
    }

}
