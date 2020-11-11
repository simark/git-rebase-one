This is a small script I use to rebase branches one commit at a time.

When rebasing feature branches that contain significant changes and severely
conflict with upstream master (possibly because the feature branch is lagging
behind quite a lot), rebasing directly on top of upstream master may be
overwhelming, there are too many big conflicts and it's difficult to understand
how to resolve each one.

Ifind it easier to do it in small steps that incrementally bring the feature
branch closer to upstream master.  At the extreme, we can do it one commit at a
time, and this is exactly what this script does.

Here's an illustration.  Imagine you have this scenario:

        |--  lots of commits  --|
        v                       v
    o---o---o---o---o---o---o---o  master
         \
          o---o---o my-branch

Run `git rebase-one master` once, that brings you here:

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

1. resolve the conflict
2. finish the aborted rebase operation with `git rebase --continue`
3. resume using `git-rebase-one` to continue your journey towards a fully rebased branch

To install `git-rebase-one`, just copy it anywhere in your `$PATH` and ensure
it is executable.
