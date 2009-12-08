Python-Vim-IDE
==============

There will be multiple branches.  The first branch will be the basic branch.
The basic branch will stay true to vim defaults, adding PEP008 and basic
onmicomplete, folding and path-hacking for django settings with few/no remaps.
I will branch from here with a more featureful config with nerdtree, supertab and more.

The idea will be that one can check it out and symlink to $VIMRUNTIME and change
configs just by checking out a different branch.


Current details of basic
========================

* Syntax highlighting

    * (http://www.vim.org/scripts/script.php?script_id=790)
    * now in .vim/syntax/python.vim

* Indention

    * simple use of the following works::

            if has("autocmd")
              filetype plugin indent on
            endif

    I uncommented this from my global /etc/vim/vimrc

* Folding

    * Just going to use indentation folds from the default .vimrc

        :help fold

        zM to fold everything
        zR to unfold everything
        za to toggle the current fold
        zA to recursively toggle the current fold

        Everything is unfolded to start.

* Code completion

    * Going with regular http://www.vim.org/scripts/script.php?script_id=1542

        still <c-x><c-o> for omnicomplete (may remap to <s-tab>)
        still <c-p> for keyword completion (may remap to <tab>)

    * :help preview

    To see how to do things like close the preview viewport (:pc)


