Installation
------------

To install `git-rebase-one`, just copy it anywhere in your `$PATH` and ensure
it is executable.

Synopsis
--------

    git-rebase-one TARGET-REF [N-COMMITS]

`TARGET-REF` is the commit ref to target (e.g. a branch name).  `N-COMMITS` is
the number of commits to rebase onto.  `git-rebase-one` will rebase the current
`HEAD` over `N-COMMITS` towards `TARGET-REF`.

`git-rebase-one` can also be invoked as `git rebase-one`.

Description
-----------

`git-rebase-one` is a tool to help rebase git branches incrementally.

When rebasing branches that contain significant changes and severely conflict
with the branch they are being rebased one (possibly because the branch is
lagging behind quite a lot), rebasing in one shot may be overwhelming, there
are too many big conflicts and it's difficult to understand how to resolve each
one.

It is easier to do it in small steps that incrementally bring the branch closer
to the target.  At the extreme, we can do it one commit at a time.

Here's an illustration.  Imagine you have this scenario:

        |--  lots of commits  --|
        v                       v
    o---o---o---o---o---o---o---o  master
         \
          o---o---o my-branch

Run `git-rebase-one master` once, that brings you here:

    o---o---o---o---o---o---o---o  master
             \
              o---o---o my-branch

Run it again, that brings you here:

    o---o---o---o---o---o---o---o  master
                 \
                  o---o---o my-branch

Run it over and over until finally the branch is fully rebased:

    o---o---o---o---o---o---o---o  master
                                 \
                                  o---o---o my-branch

Doing the rebase one commit at a time makes it easier to handle conflicts,
because when a conflict happens, you know exactly which upstream commit your
code conflicts with.  You can read that commit's log to understand it, and
apply the necessary changes in your code.

Of course, doing this by hand is tedious, but you can easily run it in a while
loop:

    $ while git rebase-one master; do : ; done

This will keep rebasing until the branch is fully rebased or a conflict occurs.
If a conflict occurs:

1. resolve the conflict, `git add` the conflicted files
2. finish the aborted rebase operation with `git rebase --continue`
3. resume using `git-rebase-one` to continue your journey towards a fully rebased branch

Rebasing over one commit at a time can however be unnecessarily time and
CPU-intensive.  `git-rebase-one` accepts an optional `N-COMMITS` parameter that
indicates how many commits at a time to rebase over.

The helper script `converge.sh` (which is currently a bit rough, would need to
be cleaned up) accelerates that by making a binary search, when encountering a
conflict.  It starts by trying a rebase over 128 commits (an arbitrary number).
It it succeeds, great.  If it fails, it tries to rebase over 64 commits.  And
so on until you are rebased on the first commit that would give a conflict.
Invoke it as:

    converge.sh [TARGET-REF]
