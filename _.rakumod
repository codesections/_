unit module _;

class X::PatternMatch::Unreachable is Exception is export {
    has Signature $.shadowed is required;
    has Signature $.prior     is required;

    method message { "The pattern\n $.shadowed.gist() \nwill never be matched because it is entierly "
                     ~"shaddowed by the prior pattern\n $.prior.gist()\n" }
}

class X::PatternMatch::NoMatch is Exception is export {
    has Str $.capture is required;
    has Code @.branches   is required;

    method message { "Cannot match the pattern $.capture.gist(); none of these branches match:\n"
                     ~ @.branches.map(*.signature.gist).join("\n").indent(4)
                     ~ "\nIf you would like to provide a default pattern, you can do so with a capture:\n"
                     ~ '-> | { #`[code that handles default case] }'.indent(4) }
}
sub signature-with-literals($_ --> List()) {
    .signature.params.map: -> $param { given $param.raku {
        m/^\s?[ $<number>=[ '-'? \d+ ['.' \d+]? 'e0'? ]
              | $<str>   =[ '"'  <-["]>*  '"'         ] ] $/;

        when $<number> { (+$<number>).WHAT }
        when $<str>    { Str               }
        default        { $param.type       }}}}

sub shadows(&prior-fn, &cur-fn) {
    &prior-fn.signature ~~ &cur-fn.signature
      or &prior-fn.signature.params.grep({ .sigil eq '$' && .type !=:= Any})
         && &prior-fn.&signature-with-literals ~~ &cur-fn.signature
}

sub choose(:on($topic) is raw = callframe(2).my<$_>, *@fns where .grep(Block) == +$_)  is export {
    my (Bool $match, Mu $return-val);
    for @fns -> &f {
        if @fns[$++^..*].first({.&shadows: &f}) -> $_ {
           die X::PatternMatch::Unreachable.new: :shadowed(.signature) :prior(&f.signature) }
        unless $match {
            if try &f.cando($topic.List.Capture) ->$ (&fn) {
                ($match, $return-val) = (True, fn(|$topic)) } } }

    $match ?? $return-val !! die X::PatternMatch::NoMatch.new: :capture($topic.raku):branches[@fns]
}
