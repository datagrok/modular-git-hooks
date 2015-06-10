# Update a website upon `git push`

> *Update:* (February 2015) Git 2.3 now includes a feature which makes most of the work below unnecessary. Use `git config receive.denyCurrentBranch updateInstead`. This work is still useful if you're using git prior to 2.3, or if you have a post-update rendering step, or you like some of the additional features and protections these hooks provide.

If you want to use a git-managed directory to publish a website, such that you can modify your HTML locally, then `git add`, `git commit`, and `git push` to deploy your changes, you will learn from the Internet that the minimal setup is:

1. Run `git config receive.denyCurrentBranch ignore` in the remote repository on your webserver.
2. Create a git hook in that remote repository that runs `git reset --hard HEAD` after a push.

That's fine, but the few extra lines of code you'll find herein offer some additional useful features:

- It doesn't require "master" to be checked out on the remote. Any checked-out branch will be updated.
- It doesn't do useless work upon *every* push; it only modifies the directory when the checked-out branch is being updated.
- If someone modifies the work tree on the remote by hand, their changes won't be simply discarded. The clone will stop tracking the branch until you stash or discard the modifications. It displays a helpful error message too. Your commits still get accepted into the branch.
- If you don't like that feature, just `git config receive.clobberWorkTree true`.
- If you prefer to place the remote's git directory somewhere outside of the usual place (for example, if you want to prevent it from being served to the Internet), just use `git config core.worktree` and these hooks will behave properly.
- You can enable a post-update rendering step. For example, if you have a markdown processor on your webserver, you can commit changes to markdown files and they can be automatically rendered to HTML when you `git push`.

# Requirements

I use `fmt` from the `coreutils` package to text-wrap some strings. If your system doesn't have `fmt`, replace occurrences with `cat`.

These scripts were tested with `dash`, the default `sh` in Debian 7 (Wheezy) and Debian 8 (Jessie). They should also work fine if `bash` is your default system shell.

# Installation

If you have existing `post-receive`, `update`, and `post-commit` hooks, I recommend using [modular-git-hooks][] to manage them.

For automatically updating the remote work tree when you push, install the `post-receive` hook `update-upon-push`:

- if you are using `modular-git-hooks`, then copy or symlink `post-receive.d/update-upon-push` into `$GIT_DIR/hooks/post-receive.d/`
- otherwise, copy or symlink `update-upon-push.sh` to `$GIT_DIR/hooks/post-receive`.

For dealing sanely with uncommitted modifications in the remote's work tree, install the `update` hook `update-upon-push-guard`:

- if you are using `modular-git-hooks`, then copy or symlink `update.d/update-upon-push-guard` into `$GIT_DIR/hooks/update.d/`
- otherwise, copy or symlink `update.d/update-upon-push-guard` to `$GIT_DIR/hooks/update`.

For automatically running `make` after the changes have been applied, install the `post-commit` hook `make`. Be aware that this script is a stupidly simple two lines of code; you're encouraged to modify it or write your own to suit your needs.

- if you are using `modular-git-hooks`, then copy or symlink `post-checkout.d/make` into `$GIT_DIR/hooks/post-checkout.d/`
- otherwise, copy or symlink `post-checkout.d/make` to `$GIT_DIR/hooks/post-checkout`.

# License

Copyright 2015 [Michael F. Lamb][]. This software is released under the terms of the [GNU General Public License][], version 3 or any later version.

[Michael F. Lamb]: http://datagrok.org
[GNU General Public License]: http://www.gnu.org/copyleft/gpl.html
[modular-git-hooks]: https://github.com/datagrok/modular-git-hooks
