Python-Vim-IDE
==============

This is my vim config for hacking on Python. I hope you like it.
I use default vim and SublimeText2 a lot as well.


Installation
============

Back up your ~/.vimrc and ~/.vim directory (or in you $VIMRUNTIME if not in home dir).
Checkout this project somewhere.
Symlink the .vimrc and .vim directory into your home directory (or $VIMRUNTIME).


Details
=======

* Syntax highlighting

    * (http://www.vim.org/scripts/script.php?script_id=790) in .vim/syntax/python.vim

* Tab completion (http://www.vim.org/scripts/script.php?script_id=1643)

    * Tab after a non-whitespace character (except those below) does keyword completion <c-p>

    * Tab after `/` does filename completion <c-x><c-f>

    * Tab after `.` does omnicompletion (http://www.vim.org/scripts/script.php?script_id=1542)

        * <leader>q (insert or command mode) will close the preview port. (:pc)

        * <S-Tab> (shift+tab) will do regular keyword completion after `.` instead of omnicompletion.

        * Enter a virtualenv, your python path should be respected (http://sontek.net/blog/detail/turning-vim-into-a-modern-python-ide#virtualenv)

* Flake8

    * https://github.com/alfredodeza/khuno.vim

        * You will need to install flake8 with pep8 and pyflakes globally to get this.

        * this plugin rocks.

        * hit <F7> or fn+F7 as a shortcut to Khuno show.

* Folding

    * Just using indentation folds from the default .vimrc (I don't use folding)::

        :help fold

        zM to fold everything
        zR to unfold everything
        za to toggle the current fold
        zA to recursively toggle the current fold

        Everything is unfolded to start.

* Django settings:

    Before launching vim (or mvim) just set the environment variable::

        export DJANGO_SETTINGS_MODULE="myproject.settings"

TODO::

    Probably should look at this pathogen thing and Command+T or somesuch.

