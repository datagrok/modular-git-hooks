# A collection of useful hooks

The scripts in this directory are intended for use with [modular-git-hooks][].

None of these files are required for `dispatch` to work.

In many cases, these hooks may be used *without* `dispatch` if you wish, and if you only need one hook per hook-type.

If you have cloned modular-git-hooks to some system-level location like `/opt/lib/githooks/`, and you have used `install-dispatch` to get `dispatch` symlinked into your repository's `.git/hooks` directory, you may install any of these examples by symlinking to them. The result looks like:

    /var/www/html/mysite/
    └── .git/
        └── hooks/
            │
            ├── post-checkout -> /opt/lib/modular-git-hooks/dispatch
            ├── post-checkout.d
            │   └── make -> /opt/lib/modular-git-hooks/hooks/post-checkout.d/make
            │
            ├── post-receive -> /opt/lib/modular-git-hooks/dispatch
            ├── post-receive.d
            │   └── update-upon-push -> /opt/lib/modular-git-hooks/hooks/post-receive.d/update-upon-push
            │
            ├── update -> /opt/lib/modular-git-hooks/dispatch
            └── update.d
                └── update-upon-push-guard -> /opt/lib/modular-git-hooks/hooks/update.d/update-upon-push-guard

## Recipes

- ["git push" to update your website][] if you have a git-managed directory on your webserver

## To-do

- TODO "git push" to update your website if you have a "dumb" webserver that may only receive files
- TODO detect/reject/warn about files that shouldn't or probably shouldn't be in the repo like .egg-info, .pyc, .orig (defaults + configurable with git config) (server and local)
- TODO detect/reject code that has merge markers left in
- TODO warn about big binary files
- TODO detect/reject/warn about big files that get added and removed in the same push, needlessly inflating the history
- TODO apply linters, style checks, schema validators to source code (local vs. remote)
- TODO check to see if there will be conflicts when merging with parent branch
- TODO access controls to special protected branches
- TODO abstract into a helper library the pattern of "warn about problems using local hooks to help devs, block those same problems using remote hooks to protect (certain branches of) the repo"

["git push" to update your website]: update-upon-push.md

# License

Copyright 2015 [Michael F. Lamb][]. This software is released under the terms of the [GNU General Public License][], version 3 or any later version.

[Michael F. Lamb]: http://datagrok.org
[GNU General Public License]: http://www.gnu.org/copyleft/gpl.html
[modular-git-hooks]: https://github.com/datagrok/modular-git-hooks
