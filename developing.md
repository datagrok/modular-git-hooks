# Developing your own hooks

The executable files in each `$hook.d` directory have the same semantics as normal git hooks: they are executable scripts or binaries like any other. They are passed the same arguments and data on standard input that git normally passes to its hooks, as described by the [githooks(5) man page][].

Any hooks that are not marked executable are ignored.

Hooks whose filenames begin with `.` or which end with any of the following are ignored: `.sample`, `.rpmsave`, `.rpmorig`, `.rpmnew`, `.swp`, `,v`, `~`, `,`, `.dpkg-old`, `.dpkg-dist`, `.dpkg-new`, `.dpkg-tmp`

The `dispatch` script will set the following variables into the environment for all hooks:

    null_commit - the special "null commit" value meaning a branch is being deleted
    empty_tree - the special "empty tree" value meaning HEAD does not exist
    head_hash - the hash corresponding to HEAD, or empty_tree if HEAD does not exist
