unit module Print::Dbg;
our proto dbg(|) is export {*}
multi dbg($_ is raw) {
    note "[$(.file.IO.basename ~':'~ .line with callframe(1))]  "
        ~( ('' R// try "$(.^name) $(.VAR.name) = ") ~.raku );
    $_}
multi dbg(+args) {
    note "[$(.file.IO.basename ~':'~ .line with callframe(1))]  "
         ~("($_)" with args.map({('' R// try "$(.^name) $(.VAR.name)=") ~.raku }).join: ", ");
    args}
