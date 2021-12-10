# _::Text::Paragraphs

Provides a `paragraphs` function analogous to Raku’s `lines`.  This function splits a `Str` or the
contents of a file into paragraphs.

It can detect two types of paragraphs.  The first type is a sequence of lines separated by blank
lines.  For example, this text is formatted as three paragraphs of this type:

```text
We do not all have to write like Faulkner, or program like Dijkstra. I
will gladly tell people what my programming style is, and I will even
tell them where I think their own style is unclear or makes me jump
through mental hoops.

But I do this as a fellow programmer, not as the Perl god. Some
language designers hope to enforce style through various typographical
means such as forcing (more or less) one statement per line.

This is all very well for poetry, but I don't think I want to force
everyone to write poetry in Perl. Such stylistic limits should be
self-imposed, or at most policed by consensus among your buddies.
```

The second type of paragraph it can detect is indicated by an indented
first line.  Here's that same text (again as three paragraphs)
formatted in that style:

```text
    We do not all have to write like Faulkner, or program like Dijkstra. I
will gladly tell people what my programming style is, and I will even
tell them where I think their own style is unclear or makes me jump
through mental hoops.
    But I do this as a fellow programmer, not as the Perl god. Some
language designers hope to enforce style through various typographical
means such as forcing (more or less) one statement per line.
    This is all very well for poetry, but I don't think I want to force
everyone to write poetry in Perl. Such stylistic limits should be
self-imposed, or at most policed by consensus among your buddies.
```

`&paragraphs` can distinguish between text that is has initial
indentation indicating a paragraph from bulleted/numbered lists
(where indentation does not indicate a paragraph break).  Thus, the
following is one paragraph:

```text
Here are some available books, in alphabetical order:
  * Learning Raku, by brian d foy
  * Learning to program with Raku: First Steps, by JJ Merelo
  * Metagenomics, by Ken Youens-Clark
  * Parsing with Perl 6 Regexes and Grammars, by Moritz Lenz
  * Perl 6 at a Glance, by Andrew Shitov
  * Raku Fundamentals, by Moritz Lenz
  * Perl 6 Deep Dive, by Andrew Shitov
  * Think Perl 6: How to Think Like a Computer Scientist, by Laurent Rosenfeld.
A list of books published or in progress is maintained in raku.org
```
