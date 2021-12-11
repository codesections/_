unit module Print::Dbg;
our proto dbg(|) is export {*}

#| Format the [$file:$line-num] header
sub fmt-header() {'[%s:%2u] '.sprintf: callframe(3).&{.file.IO.basename, .line} }

multi dbg($_ is raw) { note fmt-header()  ~('' R// try "$(.^name) $(.VAR.name) = ") ~.raku;
                       $_ }
multi dbg(+args)     { my $arg-list = args.map({('' R// try "$(.^name) $(.VAR.name)=") ~.raku});
                       note fmt-header() ~“($arg-list.join(", "))”;
                       args }
