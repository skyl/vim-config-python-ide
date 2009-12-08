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

    * Just going to use indentation folds from the default .vimrc::

        :help fold

        zM to fold everything
        zR to unfold everything
        za to toggle the current fold
        zA to recursively toggle the current fold

        Everything is unfolded to start.

* Code completion

    * Going with regular http://www.vim.org/scripts/script.php?script_id=1542::

        still <c-x><c-o> for omnicomplete (may remap to <s-tab>)
        still <c-p> for keyword completion (may remap to <tab>)

    * :help preview

        To see how to do things like close the preview viewport (:pc)

* Django settings:

  There are two ways that you can get the settings module imported and be able to omnicomplete
  modules that rely on ``DJANGO_SETTINGS_MODULE``::  
  
        1) You can be in an environment with django and settings.py in the CWD, parent or grandparent

        2) You can be inside a virtualenv that contains pinax


supertab branch
===============

The same as above except that code completion is context sensitive and you
can get it with <tab>.  So, if you are in insert mode and you have::

    import django

you can start typing django and complete it with keyword completion::

   dja<tab>

then you can type ``.`` and ``<tab>`` again and get omnicompletion::

    django.c<tab>

this will give you a dropdown between ``conf``, ``core`` and ``contrib``


