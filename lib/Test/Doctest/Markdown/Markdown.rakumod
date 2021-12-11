unit module Test::Doctest::Markdown;
use Test;

my token doctest-comment { '<!--' <.ws> 'doctest' <(.+?)> '-->' \n {$*line-number++}}
my token any-line        { \N*? \n { $*line-number++} }
my token codefence-token { ['`' | '~'] ** 3..*}
my token info-string     { 'raku' \N* \n {$*line-number++}}

our proto doctest(|)  {*}
multi doctest(IO::Path $file) { doctest($file.slurp, :file-name($file.basename))}

multi doctest(Str $_, :$file-name = '<anon>') {
    my ($pos, $codeblock-number, $*line-number) = (0, 1, 1);
    while $pos < .chars {
        my Str() $codeblock =
            '' R// m:c($pos)• <any-line>*?
                              <doctest-comment>?
                              <codefence-token>  <.ws> <info-string>
                              <($<the-codeblock>=[ <any-line>*? ] )> {}
                              $( $<codefence-token>)
                            •;

        $pos = $/.to orelse last; # no $/.to means no codeblock found, so &last
        my %cfg = do if $<doctest-comment> -> $_ { .EVAL };

        my ($stdout, @output-comments);
        do { @output-comments = ( $codeblock ~~ m:g • '# OUTPUT: «' <(.+?)> '»' •);
             temp $*OUT = $stdout = new(
                 class { has $!txt handles <Str> = '';
                         method print(+a) { $!txt ~= a.join }}:);
             (%cfg<hidden>:v ~$codeblock).EVAL }

        if @output-comments.map({"'$_'"}).join(' .* ') -> $expected-output {
            $stdout.&like: / <$expected-output> /,
                           "Output matches code block $($codeblock-number++) from $file-name"
                               or diag "<\$expected-output> regex was: $expected-output\n"
                                      ~"from line $*line-number" }
        else { pass "No exceptions thrown in code block $($codeblock-number++) in $file-name"}
    }
}
