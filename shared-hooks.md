# A shared collection of hooks

Do you have several canonical "bare" repositories stored in a central server, and apply (many of) the same hooks to (many of) them?

Do you wish to provide a shared set of git hooks to several developers on your team for their local use with your team's repositories?

Employing `dispatch` to separate git hook behavior into modular files enables you to:

- keep all your git hooks in a single place,
- keep the hooks themselves under version control,
- easily share and apply them across all your git repositories, which enables you to
- deploy hook improvements to all your repositories simultaneously.


## Example

I have a central server that contains several bare repos, most of which I want to apply a similar set of hooks to.

    /var/repos/             # The central area where I keep all my bare repos
    ├── project1.git/
    ├── project2.git/
    ├── project3.git/
    └── ...

I have a directory on that server that contains everything needed for `dispatch` to work, and all the hooks that all my repositories might need. This directory is itself under version control, and is a clone of a bare repository.

    /opt/lib/
    ├── common-githooks/    # My local collection of useful hooks, organized for `dispatch`
    └── modular-git-hooks/  # A clone of this project, where `dispatch` lives
        ├── dispatch*
        └── install-dispatch*

Then, for each of my bare repos, I simply symlink their hooks directory to this central hooks clone. The result looks like this:

    /var/repos/             # The central area where I keep all my bare repos
    ├── project1.git/
    │    └── hooks -> /opt/lib/common-githooks/
    ├── project2.git/
    │    └── hooks -> /opt/lib/common-githooks/
    ├── project3.git/
    │    └── hooks -> /opt/lib/common-githooks/
    ├── ...
    │
    │   # you can even apply the git hooks to their own repository *mind blown*
    └── common-githooks.git/
        └── hooks -> /opt/lib/common-githooks/

After setting up the symlinks to `/opt/lib/common-githooks/`, `install-dispatch` needs to be run only once to set up `dispatch` properly. If you don't mind storing symlinks, you can even commit them to your `common-githooks` repository.

I use a similar configuration for my local clones, as well. No single hook is called for both local and remote use, so it is safe to keep both local and remote hooks in the same `common-githooks` repository!

    ~/working/
    └── project1/           # a clone of /var/repos/project1.git in my home directory
        └── .git/
            └── hooks -> /opt/lib/common-githooks/

You don't have to use my path conventions. `install-dispatch` will set up the symlinks correctly for you no matter where it lives, as long as it lives in the same directory as `dispatch`.


## Per-repository hook selection

What if you want only a *subset* of your collection of hooks to run for each different repository?

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
