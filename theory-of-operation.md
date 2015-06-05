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


