# _

`_` is a meta utility package that aggregates various small bits of Raku code that don't quite
justify their own package but that nevertheless seem worth sharing.  In particular, `_` is home to
subpackages that are:

  1. A single file (not counting tests/docs)
  2. With zero dependencies (not counting other `_` files or [core
     modules](https://docs.raku.org/language/modules-core))
  3. That's no more than 70 lines long

If you have a package or script that meets those requirements and that you'd like to include, please
feel free to open a PR.  (Or even if it slightly exceeds the requirements; I'm happy to be a bit
flexible.)

## Pronunciation

However you'd like, but I pronounce `_` in this libraries name as `&lowbar;`, just like [in
HTML](https://html.spec.whatwg.org/multipage/named-characters.html#named-character-references))

## Installation and Usage

Install `_` with `$ zef install _:auth<github:codesections>`.  Once you have done so, you can import
all of `_` with `use _;` or can selectively import sub packages by proving a list of the package
names.  For example, `use _ <Self::Recursion Word::Wrap>;` would import only the `Self::Recursion`
and `Word::Wrap` packages.

## Current submodules

Currently, `_` includes the following submodules.  You can find more information about each one in
the `README` file in its directory.

  * `Self::Recursion` - provides `&_` as an alias for `&?ROUTINE`


## What problem is `_` solving?

I want to build reliable software – software that works well, delights its users, and that isn't
subject to major security flaws.  To that end, I have two beliefs (well, ok, I have _lots_ of
beliefs, but two that I'd like to focus on now):

    * Software is more reliable when it's composed of small pieces, each of which is responsible for
      [only one task](https://en.wikipedia.org/wiki/Unix_philosophy)

    * Software is difficult to reason about – and therefore dificult to build well – when it has too
      many moving parts or systems become two big

In many instances, these two beliefs complement one another – keeping things simple will reduce the
number of pieces it takes to build software _and_ will lower the complexity of each piece.  But
there are obviously times when these two values trade off against each other.  We sometimes have to
decide whether to one pretty big software "thing" or to combine many smaller and individually less
complex alternatives.

One area where this comes up a lot is in selecting the dependencies (libraries, modules, etc) to use
in a project.  At one extreme, you can try to keep each dependency as small as possible, accepting
that this will lead to many dependencies.  Or you can focus more on relying on fewer dependencies,
even if that means some of them will be too large for you to deeply understand.

This isn't a theoretical question – different developers strike that balance in very different
ways.  So do different programming language communities.

A [2020
report](https://i.blackhat.com/USA-20/Wednesday/us-20-Edwards-The-Devils-In-The-Dependency-Data-Driven-Software-Composition-Analysis.pdf)
found that the typical JavaScript application has 377 dependencies on open source libraries – and
that 10% have over 1,400. That doesn't mean that JavaScript developers are manually installing
hundreds of libraries; most of those were transitive dependencies, not direct ones. In a way,
though, that makes it even worse: to fully understand that sort of application, the developer needs
to not only understand every package they _chose_ to depend on but hundreds of others they didn't.

On the other hand, the JavaScript packages are admirably small and single-purpose.  That same report
showed that several of the most-depended-on packages JavaScript packages are tiny – one that 86% of
JS programs use is [just four lines](https://github.com/juliangruber/isarray/blob/master/index.js)
(its a polyfill for old browsers).  Pretty much anyone can look at those four lines and be sure that
they don't contain any major bugs.

At the other end of the spectrum, the language with the fewest dependencies had an average of
just 4.  Before we get too excited about that, though, I should note that the language in question
is [Swift](https://en.wikipedia.org/wiki/Swift_(programming_language)) and that the report only
covered _open source_ dependencies.  I don't have a citation, but I don't think it's a stretch to
believe that the vast majority of Swift programs depend on a large volume of Apple code, much of
which we can't look at even if we wanted to.

So it looks like we're faced with a spectrum of options, and both extremes are pretty frightening.
At one extreme, you can end up with easy-to-comprehend libraries – but in an overwhelming quantity;
at the other, a you get a manageable number of dependencies, but each one is giant enough to be
pretty impenetrable without dedicated study.  Of course it's possible to avoid both extremes and
settle somewhere in the middle.  But that risks a worst-of-both worlds outcome, where you have too
many dependencies to realistically track *and* your individual dependencies are too large to fully
comprehend.

`_` is my attempt to help the Raku ecosystem strike a better balance between too-many-small
libraries and libraries that are too large to deeply understand.  My hope is that aggregating many
small and still independent libraries into `_` will play a role in reducing the average dependencies
in a typical Raku program without adding anything so large that it defies easy understanding.

## Not a new idea

Of course, creating this sort of utility library is hardly a new idea; I think programmers have been
keeping a `./utils` directory for pretty much as long as they've had directories.  And, in
particular, the same report I cited before also showed that 88% of JavaScript libraries depend on
the [Lodash](https://lodash.com/) utility library.  (I'm aware of the similarity in name, though
calling this `_`/Lowbar is less about homage to Lodash and more a case of convergent evolution; when
a library isn't _about_ any one thing, it just makes sense to use the one non-alphabetic character
available.  And, besides, the other obvious name, 'Utils', is [somewhat
taken](https://github.com/Util)).

As Lodash proves, a utility library like this is no panacea – JavaScript have a widely used utility
library and _still_ has an explosion of other dependencies.  I'm well aware that it will take much
more than `_` to have the low-dependency Raku ecosystem we'd like.

But still, I'm optimistic that `_` can do bit more than Lodash and similar utility libraries for
three reasons.  First, Lodash and other JS utility libraries have to work from the fairly small
JavaScript standard library; many (most?) of the utilities they provide already built in with Raku.
Our larger standard library frees libraries like this to have a bit broader of a focus, which should
help increase the number of dependencies we can replace.

Second, because many utility libraries are attempting to supplement the standard library, they
typically put a lot of emphasis on developing a standard and coherent API – they're building a
single library designed to be used as one coherent whole.  Since we're operating at a bit higher
level – Raku's standard library is great; `_` is mostly about things that don't belong in Core – we
have the freedom to let each sublibrary be a bit more individual.

And, finally, we have the secret weapon of any Raku project – Raku itself.  I've said that `_`
submodules should be under 70 lines.  That's so that each one can fit on a single page; you can
literally look at all the code at one time.  That sort of global visibility is hugely empowering,
but the brevity can also be limiting – there are, of course, limits to what you can achieve in a
single page of code.  It's my belief that Raku's unrivaled expressiveness will let us fit far more
onto a single, clearly written page of code than we could if writing in any other programming
language.  If I'm right about that, then the range of problems that `_` can solve without losing
it's comprehensibility is correspondingly expanded as well.
