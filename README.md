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

This project contains:

- The executable script `dispatch`, which is *all that is needed* from this project to enable the use of multiple git hooks per git hook type.
- `install-dispatch`, which is a little helper script that will get `dispatch` set up for you.
- `tests/`, a set of functional tests to prevent me from breaking this code.
- `hooks/`, a collection of *optional* hooks that work well with `dispatch`, that you may install where useful. For more information, see [the hooks README](hooks/README.md)

## Contents

- [Setting up a single repository to employ multiple hooks](installation.md)
- [Setting up a collection of hooks shared across multiple repositories](shared-hooks.md), including:
    - how to easily enable and disable installed hooks with `git config`
    - how to mark hooks as enabled-by-default or disabled-by-default
- [Theory of operation](theory-of-operation.md)
- [A collection of hooks that you might like to use with dispatch](hooks/)
- [Developing your own hooks for use with dispatch](developing.md)
- [Similar tools and to-do](notes.md)

## License

Copyright 2014 [Michael F. Lamb](http://datagrok.org). This software is released under the terms of the [GNU General Public License](http://www.gnu.org/licenses/gpl.html), version 3.

[githooks(5) man page]: https://www.kernel.org/pub/software/scm/git/docs/githooks.html
