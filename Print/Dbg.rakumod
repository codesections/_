unit module Dbg;
proto dbg(|) is export {*}
multi dbg($_ is raw) {
    note "[$(.file.IO.basename ~':'~ .line with callframe(1))]  "
        ~indir($?FILE.IO.parent, { ('' R// try "$(.^name) $(.VAR.name) = ") ~.raku });
    $_}
multi dbg(+args) {
    note "[$(.file.IO.basename ~':'~ .line with callframe(1))]  "
         ~indir($?FILE.IO.parent, {
               "($_)" with args.map({('' R// try "$(.^name) $(.VAR.name)=") ~.raku }).join: ", " });
    args}
