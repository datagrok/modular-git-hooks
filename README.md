# modular-git-hooks

Sometimes, you want to perform several different actions in one git hook. For example, you might find several git pre-commit hooks online, all of which you would like to enable in your git repository.

One fragile way to accomplish this is to copy-and-paste all of the code from the various hooks into the single hook script that git requires. A slightly less-horrible but still-unpleasant mechanism is to create a git hook which explicitly invokes each of your other scripts.

This repository demonstrates a technique that gives you a separate directory for each type of git hook, allowing you to keep each hook action in its own modular script. Toss as many scripts as you like into the appropriate directory and they will all be executed, without editing configuration files or launcher-scripts.

<table><tr><th>Before</th><th>After</th></tr><tr><td><pre>
.git/
└── hooks/
    └── pre-commit*
</pre>
<p>(Where <code>pre-commit</code> performs formatting, linking, unit testing, and frobnicating)</p>
</td><td><pre>
.git/
└── hooks/
    ├── pre-commit.d/
    │   ├── format-code.sh*
    │   ├── run-linter.py*
    │   ├── unit-tests*
    │   └── frobnicate.rb*
    └── pre-commit -> /path/to/dispatch*
</pre></tr></table>

Shell and `run-parts` are its only dependencies. If your system does not include `run-parts`, or if it includes a faulty one like CentOS 5 does, there's a good-enough one in my gist [datagrok/run-parts.sh][]

Most hook scripts should work unmodified within a hook-script directory. See the note below under "Developing your own hooks" to see how to modify `pre-push`, `pre-receive`, and `post-receive` hooks to work correctly.

[datagrok/run-parts.sh]: https://gist.github.com/datagrok/43bc8077fbf9644f26b3


## Setup

Until I have this packaged up for easy installation in various operating systems, there are a variety of ways you can use this code:

Basically:

1. get `dispatch` onto your system, somewhere. It doesn't need to be on the
   `$PATH`. You can keep it in your `.git/hooks/` directory if you prefer. I recommend `/opt/lib/githooks/dispatch`.
2. Ensure `run-parts` is somewhere in your `$PATH`.
3. For each git hook, for example `pre-commit`:
    1. Create a `.d` directory for it: `mkdir .git/hooks/pre-commit.d`
    2. Move the existing hook, if it exists, into that directory: `mv .git/hooks/pre-commit .git/hooks/pre-commit.d/default`
    3. Create a symlink to `dispatch` named for the hook: `ln -s dispatch .git/hooks/pre-commit`


# A shared collection of hooks

Do you have several canonical "bare" repositories stored in a central server, and apply some of the same hooks to all (or a subset) of them?

Do you wish to provide a shared set of git hooks to several developers on your team for their local use with your team's repositories?

Employing `dispatch` to separate git hook behavior into modular files enables you to:

- keep your git hooks better organized,
- keep the hooks themselves under version control,
- easily share and apply them across all your git repositories, which enables you to
- deploy hook script improvements to all your repositories simultaneously.


## Example

I have a central server that contains several bare repos, most of which I want to apply a similar set of hooks to.

I have a directory on that server that contains everything needed for `dispatch` to work, and all the hooks that all my repositories might need. This directory is itself under version control, and is a clone of a bare repository.

Then, for each of my bare repos, I simply symlink their hooks directory to this central hooks clone. The result looks like this:

    /var/repos/ # This is the central area where I keep all my bare repos
    ├── project1.git/
    │    └── hooks -> /opt/lib/common-githooks/
    ├── project2.git/
    │    └── hooks -> /opt/lib/common-githooks/
    ├── project3.git/
    │    └── hooks -> /opt/lib/common-githooks/
    │
    │   # you can even apply the git hooks to their own repository *mind blown*
    └── common-githooks.git/
        └── hooks -> /opt/lib/common-githooks/

    /opt/lib/
    ├── common-githooks/    # my local collection of useful hooks, organized for `dispatch`
    │   ├── .git/           # which is itself under version control
    │   │
    │   ├── commit-msg.d/   # these directories contain all my hook scripts (not shown.)
    │   ├── post-update.d/
    │   ├── pre-commit.d/
    │   ├── prepare-commit-msg.d/
    │   ├── update.d/
    │   │
    │   │                   # symlinks from the hooks `git` looks for to `dispatch`
    │   ├── commit-msg -> /opt/lib/modular-git-hooks/dispatch*
    │   ├── post-update -> /opt/lib/modular-git-hooks/dispatch*
    │   ├── pre-commit -> /opt/lib/modular-git-hooks/dispatch*
    │   ├── prepare-commit-msg -> /opt/lib/modular-git-hooks/dispatch*
    │   └── update -> /opt/lib/modular-git-hooks/dispatch*
    │
    └── modular-git-hooks/  # a clone of this project, where `dispatch` lives
        ├── .git/
        ├── README.md
        ├── dispatch*
        └── install-dispatch*

I use a similar configuration for my local clones, as well. No single hook script is called for both local and remote use, so it is safe to keep both local and remote hooks in the same repository!


## Per-repository hook selection

What if you want only a subset of your collection of hooks to run for each different repository?

Just have each hook check for a 'git config' value and abort or continue as appropriate. In a script named, for example, `hooks/update.d/frobnicate.sh`, we might use one of these four mechanisms to make it easy to enable or disable the hook with a simple `git config ...`:

    #!/bin/sh

    # In practice, we'd only use one of these four mechanisms:

    # 1. Always run unless the user sets "git config hooks.performFrobnication false"
    [ "$(git config --bool hooks.performFrobnication) || echo true)" = "true" ] || exit 0

    # 2. Always run unless the user sets "git config hooks.skipFrobnication true"
    [ "$(git config --bool hooks.skipFrobnication) || echo false)" = "false" ] || exit 0

    # 3. Only run if the user sets "git config hooks.performFrobnication true"
    [ "$(git config --bool hooks.performFrobnication) || echo false)" = "true" ] || exit 0

    # 4. Only run if the user sets "git config hooks.skipFrobnication false"
    [ "$(git config --bool hooks.skipFrobnication) || echo true)" = "false" ] || exit 0

    echo "Performing frobnication..."
    ...


# Theory of operation

## Hook types

From git documentation, the hooks that git cares about are:

    local hooks:

        pre-applypatch      \
        applypatch-msg      |- Invoked by "git am"
        post-applypatch     /

        pre-commit          \
        prepare-commit-msg  |- Invoked by "git commit"
        commit-msg          |
        post-commit         /

        pre-rebase          - invoked by "git rebase"
        post-checkout       - invoked by "git checkout"
        post-merge          - invoked by "git merge"
        pre-push            - invoked by "git push"
        pre-auto-gc         - may veto "git gc --auto"
        post-rewrite        - invoked by "git rebase" and "git commit --amend"

    remote hooks:

        pre-receive         \
        update              |- Invoked on remote by "git push" on local
        post-receive        |
        post-update         /

Local hooks fire when performing various git actions in a local repository.  Remote hooks fire in upstream repositories when using "git push" and similar commands to send updates to them. See `man githooks` for more information about how git invokes these scripts.

Since there are no single hook scripts that are called for both local and remote, it is safe to keep both local and remote hooks in the same repository.


## Walk-through

By default, most githooks are contained within a single script, and the git hooks directory looks like this after some have been enabled:

    hooks/
    ├── commit-msg*
    ├── post-update*
    ├── pre-commit*
    ├── prepare-commit-msg*
    └── update*

We want to perform potentially many different behaviors for each hook, and turn some of those behaviors off for certain repositories, and not cause git to complain during updates if one developer uses a hook that another does not. So, we break each of the git hook scripts into a directory containing many mini-hooks, and the original hook script is replaced with a (symlink to a) dispatcher. The result looks like this:

    hooks/
    ├── commit-msg.d/
    ├── post-update.d/
    ├── pre-commit.d/
    ├── prepare-commit-msg.d/
    ├── update.d/
    ├── dispatch*
    ...

Each hook gets its own directory containing mini-hook scripts, each of which will be run by the dispatch script when appropriate.

To cause git to employ the dispatch script, each of git's hooks becomes a symlink to the dispatch script:

    ...
    ├── applypatch-msg -> dispatch*
    ├── commit-msg -> dispatch*
    ├── post-commit -> dispatch*
    ├── post-receive -> dispatch*
    ├── post-update -> dispatch*
    ├── pre-applypatch -> dispatch*
    ├── pre-commit -> dispatch*
    ├── prepare-commit-msg -> dispatch*
    ├── pre-rebase -> dispatch*
    ├── pre-receive -> dispatch*
    └── update -> dispatch*

The `dispatch` script provided by this project need not necessarily live in the repo that collects all your hook scripts, as shown here. One might prefer to install `dispatch` at the system level, for example a clone of this project at /opt/lib: `/opt/lib/modular-git-hooks/dispatch`, as I have shown in an earlier example. Or, your hook scripts repo might add this project as a git submodule.


## Developing your own hooks

The executable files in each `$hook.d` directory have the same semantics as normal git hooks: they are executable scripts or binaries like any other. With the exception of `pre-push`, `pre-receive`, and `post-receive`, they are passed the same arguments that git normally passes to its hooks.

Any hooks that are not marked executable are ignored.

`pre-push`, `pre-receive`, and `post-receive` hooks are unique in that git normally provides those hooks with information on standard input. In order to multiplex this information to all mini-hooks, dispatch captures git's data into a temporary file and provides the filename as the first argument to these hooks. It is then the hook's responsibility to read and parse the file instead of reading from standard input.

The dispatch script will set into the environment for all hooks:

    null_commit - the special "null commit" value meaning a branch is being deleted
    empty_tree - the special "empty tree" value meaning HEAD does not exist
    head_hash - the hash corresponding to HEAD, or empty_tree if HEAD does not exist


## To do

If I were to re-implement `run-parts` within `dispatch` instead of employing the one Debian provides, it would allow me to add the following features:

- allow pre-push, pre-receive, and post-receive hooks to work, unmodified, by passing their data on standard in like they expect.

- adopt a filename convention that would allow the dispatch script to manage which subscripts get run, rather than insisting that subscripts abort themselves when appropriate.

- easier compatibility with CentOS 5, Windows and OS X users, whose systems do not include a working `run-parts`.


## Similar tools

- [pre-commit](http://pre-commit.com/) is a framework only for pre-commit hooks and requires you to modify configuration files.
- ...


## License

Copyright 2014 [Michael F. Lamb](http://datagrok.org). This software is released under the terms of the [GNU General Public License](http://www.gnu.org/licenses/gpl.html), version 3.
