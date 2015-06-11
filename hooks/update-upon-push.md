# Update a website upon `git push`

> *Update:* (February 2015) Git 2.3 now includes a feature which makes most of the work below unnecessary. Use `git config receive.denyCurrentBranch updateInstead`. This work is still useful if you're using git prior to 2.3, or if you have a post-update rendering step, or you like some of the additional features and protections these hooks provide.

If you have shell access to a webserver hosting a website, you've probably thought about using git to automate publishing to that website: `git clone` your remote website directory onto your local workstation, `git add` and `commit` changes, and see it go live when you `git push`.

(What if I don't have shell access? What if the webserver doesn't have git, or the tools I use to render my source files to HTML? What if I'm hosting on [DreamObjects](https://www.dreamhost.com/cloud/storage/), [GitHub Pages](https://pages.github.com/), [Amazon S3](http://docs.aws.amazon.com/gettingstarted/latest/swh/website-hosting-intro.html), or using [djb's publicfile](http://cr.yp.to/publicfile.html)? Coming soon.)

You will learn from the Internet that the minimal setup is:

1. Run `git config receive.denyCurrentBranch ignore` in the remote repository on your webserver.
2. Create a git hook in that remote repository that runs `git reset --hard HEAD` after a push.

That's fine, but a few helper hooks on the remote can make things simple and safe:

- [update-upon-push][], a `post-receive` hook that updates the code on the remote after a `git push`.
- [update-upon-push-guard][], an `update` hook that prevents `update-upon-push` from clobbering any changes made by hand (without git) on the webserver side.
- [make][], a super simple `post-checkout` hook that runs `make` after the pushed code is deployed.

Some features of these scripts:

- It's unnecessary for "master" to be checked out on the remote. Any checked-out branch will be updated when you push to it.
- It doesn't do useless work upon *every* push; it only modifies the directory when the checked-out branch is being updated.
- If someone modifies the work tree on the remote by hand, their changes won't be simply discarded. The clone will stop tracking the branch until you stash or discard the modifications. It displays a helpful message too. Your commits still get accepted into the branch, just not deployed.
- If you don't like that feature, just `git config receive.clobberWorkTree true` to always overwrite any modifications that git doesn't know about.
- If you want to prevent the `.git` directory on the webserver from being served to the Internet, you can place it outside of your `DocumentRoot` and use `git config core.worktree` to tell it where the directory is that it should deploy to.
- You can enable a post-update rendering by creating a Makefile. For example, if you have a markdown processor on your webserver, you can commit changes to markdown files and they can be automatically rendered to HTML when you `git push`.

# Requirements

I use `fmt` from the `coreutils` package to text-wrap some strings. If your system doesn't have `fmt`, replace occurrences with `cat`.

These scripts were tested with `dash`, the default `sh` in Debian 7 (Wheezy) and Debian 8 (Jessie). They should also work fine if `bash` is your default system shell.

# Installation

I recommend using [modular-git-hooks][]' `dispatch` utility to manage these hooks, especially if you have any existing `post-receive`, `update`, or `post-commit` hooks that you prefer to keep. But this is not required.

You can use `update-upon-push` alone, or together with `update-upon-push-guard`. The latter doesn't really do anything useful by itself.

You can use `make` alone, or with the other tools.

Below, `$GIT_DIR` refers to the `.git` directory on the remote (the webserver).

## With `dispatch`

- symlink or copy [update-upon-push][] into `$GIT_DIR/hooks/post-receive.d/`
- symlink or copy [update-upon-push-guard][] into `$GIT_DIR/hooks/update.d/`
- symlink or copy [make][] into `$GIT_DIR/hooks/post-checkout.d/`

## Without `dispatch`

- symlink or save [update-upon-push][] as `$GIT_DIR/hooks/post-receive`
- symlink or save [update-upon-push-guard][] as `$GIT_DIR/hooks/update`
- symlink or save [make][] as `$GIT_DIR/hooks/post-checkout`

# License

Copyright 2015 [Michael F. Lamb][]. This software is released under the terms of the [GNU General Public License][], version 3 or any later version.

[Michael F. Lamb]: http://datagrok.org
[GNU General Public License]: http://www.gnu.org/copyleft/gpl.html
[modular-git-hooks]: https://github.com/datagrok/modular-git-hooks
[update-upon-push]: post-receive.d/update-upon-push
[update-upon-push-guard]: update.d/update-upon-push-guard
[make]: post-checkout.d/make
