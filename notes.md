# Similar tools

- [pre-commit](http://pre-commit.com/) is a framework only for pre-commit hooks that requires you to modify yaml configuration files to manage hooks. It is part package-manager, and does a lot of work that we don't do to build out the infrastructure needed to run any requested hook.
- [icefox/git-hooks](/icefox/git-hooks) includes a feature to search for hooks in multiple trees. Doesn't replay standard input to hooks, so `pre-push`, `pre-receive`, `post-receive`, and `post-rewrite` hooks will fail. Fail-fast (discontinues running hooks upon first hook failure). No means to individually disable discovered hooks.
- [mcwhittemore/git-hook-modules](/mcwhittemore/git-hook-modules) requires node.js. Uses a custom-format configuration file.

# To do

- `githooks` is typically one word. Rename this project to `modular-githooks` and update documentation to match.

- By design, `dispatch` runs all the hooks in the `(hook).d` directory regardless of the exit status of any one. Is there a need for a mechanism to allow a hook to discontinue running other hooks of the current type? I'd prefer to say "no," as assuming that all hooks are orthogonal allows a future feature where hooks run in parallel.

- Propose a patch to `git` that obviates the need for this tool. (See if someone has been done this already.)

- Explore a re-implementation in any fast, compiled language with minimal run-time dependencies, like C or maybe Rust, that can produce binaries for use with old (CentOS 5) and recent Linux distributions, as well as OS X and BSD. Maybe even windows? Study how git itself is built, and mimic that.

- Improve the suite of unit tests.

- Begin [semver](http://semver.org) versioning, and keep a CHANGELOG.
