unit module _;


class X::Match::Unreachable is Exception is export {
    has Signature $.shadowed is required;
    has Signature $.prior     is required;

    method message { "The pattern\n $.shadowed.gist() \nwill never be matched because it is entierly "
                     ~"shaddowed by the prior pattern\n $.prior.gist()\n" }
}
class X::Match::NoMatch is Exception is export {
    has Capture $.capture is required;
    has Code @.branches   is required;

    method message { "Cannot match the pattern $.capture.gist(); none of these branches match:\n"
                     ~ @.branches.map(*.signature.gist).join("\n").indent(4)
                     ~ "\nIf you would like to provide a default pattern, you can do so with a capture:\n"
                     ~ '-> | { #`[code that handles default case] }'.indent(4) }
}

sub choose(:on($topic) is raw = callframe(2).my<$_>, *@fns where .grep(Block) == +$_)  is export {
    # TODO: smartmatching against the signature works post rakudo/rakudo#4573
    #       but not before.  Add a version check.

    for @fns -> &f {
        with @fns[$++^..*].first: { .signature ~~ &f.signature } {
            die X::Match::Unreachable.new: :shadowed(.signature) :prior(&f.signature) } }

    for @fns -> &f { if &f.cando($topic.List.Capture) ->$ (&fn) { return fn(|$topic) } }

    die X::Match::NoMatch.new: :capture($topic.Capture):branches[@fns]
}
