Installation
------------

To install `git-rebase-one`, just copy it anywhere in your `$PATH` and ensure
it is executable.

Synopsis
--------

    git-rebase-one [OPTIONS] TARGET-REF [N-COMMITS]

`TARGET-REF` is the commit ref to target (e.g. a branch name).  `N-COMMITS` is
the number of commits to rebase onto.  `git-rebase-one` will rebase the current
`HEAD` over `N-COMMITS` towards `TARGET-REF`.

`git-rebase-one` can also be invoked as `git rebase-one`.

Options:

  - `--sound-success`: play a sound when the tool exits successfully (a step
    completed, or the branch is up to date).
  - `--sound-failure`: play a sound when the tool exits with a failure (e.g. a
    conflict requiring manual intervention).

The sounds come from `/usr/share/sounds/freedesktop/stereo/` and are played
with whichever player is available (`pw-play`, `paplay`, `canberra-gtk-play` or
`ffplay`); if none is available, the option is silently a no-op.

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

When a conflict occurs, `git-rebase-one` prints a summary after the `git rebase`
output showing the last upstream commit that rebased cleanly.  When rebasing one
commit at a time, it also prints the exact upstream commit that conflicted.

Rebasing over one commit at a time can however be unnecessarily time and
CPU-intensive.  `git-rebase-one` accepts an optional `N-COMMITS` parameter that
indicates how many commits at a time to rebase over.

`git-rebase-one` only follows the first-parent line of `TARGET-REF`.  This
matters when `TARGET-REF` periodically merges another branch into itself.  For
example, consider a `downstream` branch that tracks `master` and from time to
time merges `master` into itself:

        o---o---o---o---o---o---o---o  master
         \       \           \
          o-------M---o-------M---o  downstream
           \
            o---o---o my-branch

When rebasing `my-branch` towards `downstream`, we step over `downstream`'s
own commits and its merge commits (`M`), but not the individual `master`
commits brought in by those merges.  Rebasing onto a merge commit incorporates
everything that merge brought in as a single step, so you converge towards
`downstream` without replaying each upstream `master` commit one by one.

The helper script `converge.sh` (which is currently a bit rough, would need to
be cleaned up) accelerates that by making a binary search, when encountering a
conflict.  It starts by trying a rebase over 128 commits (an arbitrary number).
It it succeeds, great.  If it fails, it tries to rebase over 64 commits.  And
so on until you are rebased on the first commit that would give a conflict.
Invoke it as:

    converge.sh [TARGET-REF]
