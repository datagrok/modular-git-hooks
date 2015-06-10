# Setup

> **Note to Microsoft Windows users:** on Windows, this software requires either [Cygwin version 2.0.0 or higher](https://www.cygwin.com/), or [Git-for-Windows version 2.1 or higher](http://git-for-windows.github.io/).
>
> Versions of [Cygwin 1.7.35 and older contain a bug](https://cygwin.com/ml/cygwin/2015-03/msg00270.html) that prevents this software from working properly.
>
> Versions of Git for Windows prior to 2.x include a "Git Bash" built on [msysGit](https://msysgit.github.io/), which is [built on](https://github.com/msysgit/msysgit#the-difference-between-msys-and-mingw), and inherits the Cygwin bug mentioned above. See the [git-for-windows FAQ](https://github.com/git-for-windows/git/wiki/FAQ) for more information about msysGit versus Git-for-Windows.

I have not yet packaged this utility for easy installation in various operating systems. Manual setup instructions follow.

Basically: `dispatch` is the only file you need from this project. `install-dispatch` helps to automate hooking `dispatch` up to your repositories properly, but you can do the same by hand instead, if you prefer.

## Enable `dispatch` on a single repo with `install-dispatch`

1. Put `dispatch` onto your system, somewhere.
    - It doesn't need to be on the `$PATH`. You can keep it in your repository's `.git/hooks/` directory if you prefer.
    - I recommend to just keep a clone of this project at `/opt/lib/modular-git-hooks/`.
2. Put `install-dispatch` in the same directory as `dispatch`.
    - If you're keeping a clone of this project at `/opt/lib/modular-git-hooks`, this step is done already.
3. From within your git repository, run `install-dispatch`. You may need to specify the full path to it, like `/opt/lib/modular-git-hooks/install-dispatch`. It will create symlinks named for all git hooks.
4. Create `hook.d` directories for your hooks and copy them into place. If you already had some hooks in place, this will be done for you automatically.

        # clone this project, place somewhere on the system
        git clone git@github.com:datagrok/modular-git-hooks.git
        sudo mkdir -P /opt/lib
        sudo mv modular-git-hooks /opt/lib
        # setup dispatch in my target repository
        cd ~/myproject/myrepo
        /opt/lib/modular-git-hooks/install-dispatch
        # install your favorite hooks
        mkdir .git/hooks/update.d
        mv ~/my_update_hook .git/hooks/update.d/

## Enable `dispatch` on a single repo manually

If you prefer not to use `install-dispatch`, you may manually perform the steps that it does.

1. Put `dispatch` onto your system, somewhere.
    - It doesn't need to be on the `$PATH`. You can keep it in your repository's `.git/hooks/` directory if you prefer.
    - I recommend to just keep a clone of this project at `/opt/lib/modular-git-hooks/`.
2. For each git hook type that you wish to dispatch, for example `pre-commit`:
    1. Create a `.d` directory for it: `mkdir .git/hooks/pre-commit.d`
    2. Move the existing hook, if it exists, into that directory: `mv .git/hooks/pre-commit .git/hooks/pre-commit.d/pre-commit.orig`
    3. Create a symlink to `dispatch` named for the hook type: `ln -s /opt/lib/modular-git-hooks/dispatch .git/hooks/pre-commit`

---

See also [setting up a collection of hooks shared across multiple repositories](shared-hooks.md)
