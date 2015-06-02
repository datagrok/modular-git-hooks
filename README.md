# modular-git-hooks

[![Build Status](https://travis-ci.org/datagrok/modular-git-hooks.svg?branch=master)](https://travis-ci.org/datagrok/modular-git-hooks)

Sometimes, you want to perform several different actions in one git hook. For example, you might find several useful pre-commit hooks online, all of which you would like to enable in your git repository.

One fragile way to accomplish this is to copy-and-paste all of the code from those various pre-commit hooks into the single hook that git requires, named `hooks/pre-commit`. This is, of course, impossible if some of those hooks are implemented in differing languages.

A slightly less-horrible but still-unpleasant mechanism is to create a `hooks/pre-commit` dispatching script which explicitly invokes each of the hooks you have downloaded and stored in separate files. But then you have to modify that dispatcher every time you update, deal with passing arguments and standard-input to the sub-hooks, and handle their exit statuses correctly.

This repository provides a **general-purpose `dispatch`** tool that does all that for you and requires **no modification when you add or remove hooks**. It gives you a separate directory for each type of git hook, allowing you to **keep each hook in its own file**. Toss as many hooks as you like into the appropriate directory and they will all be executed, in alphanumeric order, **without editing configuration files** or launcher-scripts. It uses `git config` for any configuration needs. It is implemented in `dash`- and `bash`-compatible shell script, which, granted, isn't the most pleasant or elegant, but on the other hand means you don't have to worry about your hooks breaking for lack of the correct version of Python, Ruby, or some other language du jour.

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

Most hooks intended for standalone use should work, unmodified, when placed within a hook-type directory.

## Setup

> **Note to Microsoft Windows users:** on Windows, this software requires either [Cygwin version 2.0.0 or higher](https://www.cygwin.com/), or [Git-for-Windows version 2.1 or higher](http://git-for-windows.github.io/).
>
> Versions of [Cygwin 1.7.35 and older contain a bug](https://cygwin.com/ml/cygwin/2015-03/msg00270.html) that prevents this software from working properly.
>
> Versions of Git for Windows prior to 2.x include a "Git Bash" built on [msysGit](https://msysgit.github.io/), which is [built on](https://github.com/msysgit/msysgit#the-difference-between-msys-and-mingw), and inherits the Cygwin bug mentioned above. See the [git-for-windows FAQ](https://github.com/git-for-windows/git/wiki/FAQ) for more information about msysGit versus Git-for-Windows.

Until I have this packaged up for easy installation in various operating systems, there are a variety of ways you can use this code:

Basically:

1. get `dispatch` onto your system, somewhere. It doesn't need to be on the `$PATH`. You can keep it in your `.git/hooks/` directory if you prefer. I recommend `/opt/lib/githooks/`.
2. put `install-dispatch` in the same directory as `dispatch`.
3. from within your git repository, run `install-dispatch`. You may need to specify the full path to it, like `/opt/lib/githooks/install-dispatch`.

If you prefer not to use `install-dispatch`, you may manually perform the steps that it does:

1. For each git hook type, for example `pre-commit`:
    1. Create a `.d` directory for it: `mkdir .git/hooks/pre-commit.d`
    2. Move the existing hook, if it exists, into that directory: `mv .git/hooks/pre-commit .git/hooks/pre-commit.d/pre-commit.orig`
    3. Create a symlink to `dispatch` named for the hook type: `ln -s dispatch .git/hooks/pre-commit`

# A shared collection of hooks

Do you have several canonical "bare" repositories stored in a central server, and apply (many of) the same hooks to (many of) them?

Do you wish to provide a shared set of git hooks to several developers on your team for their local use with your team's repositories?

Employing `dispatch` to separate git hook behavior into modular files enables you to:

- keep your git hooks better organized,
- keep the hooks themselves under version control,
- easily share and apply them across all your git repositories, which enables you to
- deploy hook improvements to all your repositories simultaneously.


## Example

I have a central server that contains several bare repos, most of which I want to apply a similar set of hooks to.

I have a directory on that server that contains everything needed for `dispatch` to work, and all the hooks that all my repositories might need. This directory is itself under version control, and is a clone of a bare repository.

Then, for each of my bare repos, I simply symlink their hooks directory to this central hooks clone. The result looks like this:

    /var/repos/             # This is the central area where I keep all my bare repos
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
    │   ├── commit-msg.d/   # these directories contain all my hooks (not shown.)
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

I use a similar configuration for my local clones, as well. No single hook is called for both local and remote use, so it is safe to keep both local and remote hooks in the same repository!

You don't have to use my path conventions. `install-dispatch` will set up the symlinks correctly for you no matter where it lives.

## Per-repository hook selection

What if you want only a subset of your collection of hooks to run for each different repository?

`dispatch` will check git config for parameters that enable or disable each hook by filename, optionally including hook type. Hooks are enabled by default, unless their filename ends in `.optional`.

You may specify which hooks to enable or disable using a `git config` parameter based on a "long form" or "short form" of their filename. "Long form" includes the hook type directory and the full filename. "Short form" omits the hook type directory, and the `.optional` extension, if it exists. Examples follow.

A hook named `pre-commit.d/format-code.sh` will be enabled by default. To disable it, use either of these commands:

    git config --bool hook.pre-commit.d/format-code.sh.enabled false
    git config --bool hook.format-code.sh.enabled false

A hook named `pre-commit.d/format-code.sh.optional` will be disabled by default. To enable it, use either of these commands:

    git config --bool hook.pre-commit.d/format-code.sh.enabled true
    git config --bool hook.format-code.sh.enabled true

Note that if you have more than one type of hook named `format-code.sh`, the "short form" will enable or disable all types of them at once. This may be useful, for a set of cooperative hooks of multiple types that must be enabled or disabled simultaneously to work properly. Just ensure you don't name-conflict with other, unrelated hooks of different hook types.

Note that if you have set configuration values in *both* "long form" (more specific) and "short form" (less specific) syntax for a hook, the "long form" takes precedence. 

# Theory of operation

## Hook types

From the [githooks(5) man page][], the hook types that git cares about are:

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

Local hooks fire when performing various git actions in a local repository. Remote hooks fire in upstream repositories when using "git push" and similar commands to send updates to them. See the [githooks(5) man page][] for more information about how git invokes these scripts.

Since there are no single hook types that are invoked for both local and remote, it is safe to keep both local and remote hooks in the same repository.


## Walk-through

By default, most git hooks are contained within a single executable file. When some have been enabled, the repository's hooks directory might look like this:

    hooks/                  # Before using the modular-git-hooks dispatch mechanism
    ├── commit-msg*
    ├── post-update*
    ├── pre-commit*
    ├── prepare-commit-msg*
    └── update*

We want to perform potentially many different behaviors for each hook, and turn some of those behaviors off for certain repositories. If the hooks themselves are managed by git, we don't want git to complain about modified files when developers sharing the hooks repository enable and disable various functionality.

So, we break each of the monolithic git hooks into a directory containing many modular hooks, and the original hook that git invokes is replaced with a (symlink to a) dispatcher. The result looks like this:

    hooks/                  # After applying this mechanism
    ├── commit-msg.d/
    ├── post-update.d/
    ├── pre-commit.d/
    ├── prepare-commit-msg.d/
    ├── update.d/
    ├── dispatch*
    ...

Above, each hook type gets its own directory containing hooks, each of which will be run by `dispatch` when appropriate. This should look familiar to anyone who has used Debian's `run-parts` tool.

To cause git to employ it, each of the hooks that git invokes becomes a symlink to `dispatch`:

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

`dispatch` need not necessarily live in the repository that collects all your shared hooks, as it does above. One might prefer to install `dispatch` at the system level, for example a clone of this project at /opt/lib might result in symlinks to `/opt/lib/modular-git-hooks/dispatch`, as shown in an earlier example. Or, your hook scripts repository might add this project as a git submodule.


## Developing your own hooks

The executable files in each `$hook.d` directory have the same semantics as normal git hooks: they are executable scripts or binaries like any other. They are passed the same arguments and data on standard input that git normally passes to its hooks, as described by the [githooks(5) man page][].

Any hooks that are not marked executable are ignored.

Hooks whose filenames begin with `.` or which end with any of the following are ignored: `.sample`, `.rpmsave`, `.rpmorig`, `.rpmnew`, `.swp`, `,v`, `~`, `,`, `.dpkg-old`, `.dpkg-dist`, `.dpkg-new`, `.dpkg-tmp`

The `dispatch` script will set the following variables into the environment for all hooks:

    null_commit - the special "null commit" value meaning a branch is being deleted
    empty_tree - the special "empty tree" value meaning HEAD does not exist
    head_hash - the hash corresponding to HEAD, or empty_tree if HEAD does not exist


## Similar tools

- [pre-commit](http://pre-commit.com/) is a framework only for pre-commit hooks that requires you to modify yaml configuration files to manage hooks. It is part package-manager, and does a lot of work that we don't do to build out the infrastructure needed to run any requested hook.
- [icefox/git-hooks](/icefox/git-hooks) includes a feature to search for hooks in multiple trees. Doesn't replay standard input to hooks, so `pre-push`, `pre-receive`, `post-receive`, and `post-rewrite` hooks will fail. Fail-fast (discontinues running hooks upon first hook failure). No means to individually disable discovered hooks.
- [mcwhittemore/git-hook-modules](/mcwhittemore/git-hook-modules) requires node.js. Uses a custom-format configuration file.

## To do

- By design, `dispatch` runs all the hooks in the `(hook).d` directory regardless of the exit status of any one. Is there a need for a mechanism to allow a hook to discontinue running other hooks of the current type? I'd prefer to say "no," as assuming that all hooks are orthogonal allows a future feature where hooks run in parallel.

- Propose a patch to `git` that obviates the need for this tool. (See if someone has been done this already.)

- Explore a re-implementation in ~~C~~ any fast, compiled language with minimal run-time dependencies, that can produce binaries for use with old (CentOS 5) and recent Linux distributions, as well as OS X and BSD. Maybe even windows? Study how git itself is built, and mimic that.

- Improve the suite of unit tests.

- Begin [semver](http://semver.org) versioning, and keep a CHANGELOG.

## License

Copyright 2014 [Michael F. Lamb](http://datagrok.org). This software is released under the terms of the [GNU General Public License](http://www.gnu.org/licenses/gpl.html), version 3.

[githooks(5) man page]: https://www.kernel.org/pub/software/scm/git/docs/githooks.html
