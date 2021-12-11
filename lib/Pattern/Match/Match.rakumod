unit module Pattern::Match;

#| Error for a shadowed pattern
class X::PatternMatch::Unreachable is Exception is export {
    has Signature $.shadowed is required;
    has Signature $.prior    is required;

    method message { "The pattern\n $.shadowed.gist() \nwill never be matched because it is entirely "
                     ~"shadowed by the prior pattern\n $.prior.gist()\n" }
}

#| Error for unmatched input – suggests a default case
class X::PatternMatch::NoMatch is Exception is export {
    has Str  $.capture  is required;
    has Code @.branches is required;

    method message { "Cannot match the pattern\n$.capture.gist.indent(4)\n"
                     ~"because none of these branches match:\n"
                     ~ @.branches.map(*.signature.gist).join("\n").indent(4)
                     ~"\nIf you would like to provide a default pattern, you"
                     ~"can do so with a capture:\n"
                     ~ '-> | { #`[code that handles default case] }'.indent(4) }
}

#| Detects whether &prior-fn totally shadows &cur-fn – that is, whether its signature accepts
#| anything that &cur-fn's signature accepts.  Because literal signatures aren't
#| introspectable, detecting literals uses crude textual heuristics.
sub shadows(&prior-fn, &cur-fn) {
    sub signature-with-literals($_ --> List()) {
        .signature.params.map: -> $param { given $param.raku {
            m/^\s?<( [ $<number>=[ '-'? \d+ ['.' \d+]? 'e0'? ]
                     | $<str>   =[ '"'  <-["]>*  '"'         ] ])> $/;

            with $/  { (val ~$_).WHAT }
            else     { $param.type    }}}}

    &prior-fn.signature ~~ &cur-fn.signature
      or &prior-fn.signature.params.grep({ .sigil eq '$' && .type !=:= Any})
         && &prior-fn.&signature-with-literals ~~ &cur-fn.signature
}

#| Run the first of the provided blocks with a signature that matches $topic
our proto choose(|) is export {*}
multi choose(:on($topic) is raw = callframe(2).my<$_>, *@fns where .grep(Block) == +$_) {
    my (Bool $match-found, Mu $return-val) = (False, Mu);
    for @fns -> &f {
        # We need to run the full loop to find shadowed cases, so don't &last after finding a match
        if @fns[$++^..*].first({.&shadows: &f}) -> $_ {
           die X::PatternMatch::Unreachable.new: :shadowed(.signature) :prior(&f.signature) }
        next if $match-found;
        if try &f.cando($topic.List.Capture) ->$ (&fn) { $match-found = True;
                                                         $return-val = fn |$topic }}

    $match-found ?? $return-val !! die X::PatternMatch::NoMatch.new: :capture($topic.raku):branches[@fns]
}
