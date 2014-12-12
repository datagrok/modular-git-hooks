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

Most hook scripts intended for standalone use should work unmodified within a hook-script directory.


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
    │   ├── ...
    │   ├── update.d/
    │   │
    │   │                   # symlinks from the hooks `git` looks for to `dispatch`
    │   ├── commit-msg -> /opt/lib/modular-git-hooks/dispatch*
    │   ├── post-update -> /opt/lib/modular-git-hooks/dispatch*
    │   ├── pre-commit -> /opt/lib/modular-git-hooks/dispatch*
    │   ├── prepare-commit-msg -> /opt/lib/modular-git-hooks/dispatch*
    │   ├── ...
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

The `dispatch` script will check git config for parameters that enable or disable each hook script. Scripts are enabled by default, unless their filename ends in `.optional`.

To disable a hook script named, for example, `pre-commit.d/format-code.sh`, use either of these commands:

    # parameter: "hook.(commit type).d/(filename).enabled"
    git config --bool hook.pre-commit.d/format-code.sh.enabled false

    # parameter: "hook.(filename).enabled"
    git config --bool hook.format-code.sh.enabled false

To enable a hook script named, for example, `pre-commit.d/frobnicate.optional`, use either of these commands:

    # parameter: "hook.(commit type).d/(filename).enabled"
    git config --bool hook.pre-commit.d/frobnicate.optional.enabled true

    # parameter: "hook.(filename, less '.optional').enabled"
    git config --bool hook.frobnicate.enabled true

This implies that if you have a pre-commit and an update hook both named `frobnicate.optional`, or both named `format-code.sh`, the second command listed in these examples will enable or disable them both. This may be useful, for a set of hooks that must be enabled simultaneously to work properly. Just ensure you don't name-conflict with other, unrelated hooks.

If git finds you have set both `hook.pre-commit.d/frobnicate.optional.enabled` and `hook.frobnicate.enabled`, it will ignore the latter (less specific) configuration. 

Some hooks may specify their own git config parameters for enabling their execution; refer to their documentation.

# Theory of operation

## Hook types

From the [githooks(5) man page](https://www.kernel.org/pub/software/scm/git/docs/githooks.html), the hooks that git cares about are:

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

    hooks/                  # Before using this mechanism
    ├── commit-msg*
    ├── post-update*
    ├── pre-commit*
    ├── prepare-commit-msg*
    └── update*

We want to perform potentially many different behaviors for each hook, and turn some of those behaviors off for certain repositories, and not cause git to complain during updates if one developer uses a hook that another does not. So, we break each of the git hook scripts into a directory containing many mini-hooks, and the original hook script is replaced with a (symlink to a) dispatcher. The result looks like this:

    hooks/                  # After applying this mechanism
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

The executable files in each `$hook.d` directory have the same semantics as normal git hooks: they are executable scripts or binaries like any other. They are passed the same arguments and data on standard input that git normally passes to its hooks.

Any hooks that are not marked executable are ignored.

Hooks whose filenames begin with `.` or end with any of the following are ignored: `.sample`, `.rpmsave`, `.rpmorig`, `.rpmnew`, `.swp`, `,v`, `~`, `,`, `.dpkg-old`, `.dpkg-dist`, `.dpkg-new`, `.dpkg-tmp`

The `dispatch` script will set the following variables into the environment for all hooks:

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
