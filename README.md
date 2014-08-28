# modular-git-hooks

Sometimes, you want to perform several different actions in one git hook. This repository demonstrates a technique that employs symlinks and Debian's `run-parts` mechanism to give you a separate directory for each hook, allowing you to keep each action in a separate script. Toss as many scripts as you like in the appropriate directory and they will all be run, without editing configuration files or launcher scripts.

<table><tr><th>Before</th><th>After</th></tr><tr><td><pre>
.git/
└── hooks/
    └── pre-commit*
</pre></td><td><pre>
.git/
└── hooks/
    ├── pre-commit.d/
    │   ├── format-code.sh*
    │   ├── run-linter.py*
    │   ├── unit-tests*
    │   └── frobnicate.rb*
    └── pre-commit -> /path/to/dispatch*
</pre></tr></table>

If you need some mini-hook to (not) run for some subset of your repositories, just have the mini-hook check for a 'git config' value and abort or continue as appropriate. This technique can be useful in the situations where:

- you have several shared canonical repositories and wish to apply a different subset of your available remote git hooks to each of them, or
- you wish to provide a shared set of git hooks to several developers on your team for their local use with your team's repositories.

Shell and `run-parts` are its only dependencies. If your system does not include `run-parts`, or if it includes a faulty one like CentOS 5 does, there's a good-enough one in my gist [datagrok/run-parts.sh][]

Most hook scripts should work unmodified as mini-hooks. See the note below under "Developing your own hooks" to see how to modify `pre-push`, `pre-receive`, and `post-receive` to work correctly.

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

In the case of a shared set of git hooks, I recommend creating a repository to hold them, organized as above, that you can clone into place at .git/hooks or symlink to as .git/hooks. See the next section for details.


## Mini-hooks repository organization

From git documentation, the git hooks that git cares about are:

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

Since there are no single hook scripts that are called for both local and remote, it is safe to keep both local and remote hooks in the same repository and simply symlink .git/hooks to a shared clone of that repository.

By default, most githooks are contained within a single script, and the git hooks directory looks like this after some have been enabled:

    hooks/
    ├── commit-msg*
    ├── post-update*
    ├── pre-commit*
    ├── prepare-commit-msg*
    └── update*

We want to perform potentially many different behaviors for each hook, and turn some of those behaviors off for certain repositories, and not cause git to complain during updates if one developer uses a hook that another does not. So, we break each of the git hook scripts into a directory containing many mini-hooks, and the original hook script is replaced with a (symlink to a) dispatcher. The result looks like this:

Each hook gets its own directory containing mini-hook scripts, each of which will be run by the dispatch script when appropriate. The dispatch script need not live here; it might assume it is available at the system level as `/opt/lib/githooks/dispatch` or it might use this repository as a submodule.

    hooks/
    ├── commit-msg.d/
    ├── post-update.d/
    ├── pre-commit.d/
    ├── prepare-commit-msg.d/
    ├── update.d/
    ├── dispatch*
    ...

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

Any mini-hooks that are not marked executable are effectively disabled.


## Developing your own hooks

The executable files in each `$hook.d` directory have the same semantics as normal git hooks: they are executable scripts or binaries like any other. With the exception of `pre-push`, `pre-receive`, and `post-receive`, they are passed the same arguments that git normally passes to its hooks.

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

- All documentation herein is [GNU Free Documentation License v1.3](http://www.gnu.org/licenses/fdl.html) unless otherwise noted.
- All source code herein is [GNU Affero General Public License v3](http://www.gnu.org/licenses/agpl.html) unless otherwise noted.
