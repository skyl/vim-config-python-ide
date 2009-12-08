"" Color scheme configuration
if has("gui_running")
    colorscheme synic
    set guifont=Consolas\ bold\ 10
else
    colorscheme synic
    " colorscheme enzyme
    " colorscheme tango-desert
    " colorscheme fruity
    " colorscheme Symfony
endif


"" Enable filetype detection and file plugins
set nocompatible
filetype on
filetype plugin on

" General
set cursorline          " underline current line
set mouse=a             " enable mouse
set laststatus=2        " always show a status line
set scrolloff=3         " keep 3 lines when scrolling
set guioptions-=L       " disable left scrollbar in GUI
set showcmd             " show partial commands in status line
set ruler               " show cursor position in status line
set list                " show tabs and spaces at end of line:
set listchars=tab:>-,trail:.,extends:>,precedes:<
set hlsearch            " highlight search matches
set incsearch           " use incremental search
set number              " show line numbers
set numberwidth=4       " line numbers take up 5 spaces
set ignorecase          " ignore case when searching
set title               " show title in console title bar
set ttyfast             " smoother changes
set shortmess=atI       " abbreviate messages and suppress welcome
set nostartofline       " don't jump to first character when paging
set nowrap              " dont wrap long lines
set wildmode=list:longest " enable nice tab completion on command line
set wildignore=*.o,*.obj,*.bak,*.exe,*.pyc,*.pyo,*.DS_Store,*.db  " ignore some file types
if has("extra_search")
    nohlsearch          " but not initially
endif

"" Hide hidden and pyc files
let g:explHideFiles='^\.,.*\.pyc$'

"" Dont Beep!
set noerrorbells        " don't beep!
set visualbell          " don't beep!
set t_vb=               " don't beep! (but also see below)

"" Backup Files
set backup              " make backups
set backupdir=~/tmp     " but don't clutter $PWD with them
if !isdirectory(&backupdir)
    " create the backup directory if it doesn't already exist
    exec "silent !mkdir -p " . &backupdir
endif

"" Hilight ends of long lines and unwanted whitespace
autocmd BufWinEnter * let w:m1=matchadd('Search', '\%>80v.\+', -1)

" Show trailing whitespace and spaces before tabs
hi link localWhitespaceError Error
autocmd Syntax * syn match localWhitespaceError /\(\zs\%#\|\s\)\+$/ display
autocmd Syntax * syn match localWhitespaceError / \+\ze\t/ display

"" Auto close pydoc after omnicompletion
autocmd CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif

"" Javascript lint and jquery syntax
autocmd BufWritePost,BufLeave,BufWinEnter *.js :JSLint
autocmd BufRead,BufNewFile *.js set ft=javascript.jquery

"" Tab navigation firefox style
:nmap <C-S-tab> :tabprevious<cr>
:nmap <C-tab> :tabnext<cr>
:imap <C-S-tab> <ESC>:tabprevious<cr>i
:imap <C-tab> <ESC>:tabnext<cr>i
:nmap <C-t> :tabnew<cr>
:imap <C-t> <ESC>:tabnew<cr>i
:map <C-w> :tabclose<cr>

"" Closetag plugin
" autocmd FileType djangohtml,html,xhtml,xml source ~/.vim/plugin/closetag.vim

"" Sane omnicompletion
let g:SuperTabDefaultCompletionType = "<c-x><c-O>"
set completeopt=menu,preview,longest
set pumheight=5

"" Sane Folding
set foldlevel=9999        " initially open all folds
" Space folds and unfolds
nnoremap <silent> <Space> @=(foldlevel('.')?'za':'l')<CR>
inoremap <Nul> @=(foldlevel('.')?'zM':'l')<CR>

"" xml folding
autocmd BufNewFile,BufRead *.xml,*.htm,*.html so XMLFolding

" ctrl+f should fullscreen
nnoremap <c-f> :ZoomWin<CR>

"" Rope refactoring tool
let ropevim_vim_completion=1
let ropevim_extended_complete=1
nnoremap <silent> <S-z> :RopeShowDoc<CR>

"" Sane whitespace and tab
set tabstop=8
set shiftwidth=4
set smarttab
set expandtab
set textwidth=79
set softtabstop=4
set autoindent
syntax on
" Trim tailing whitespace
autocmd BufWritePre *.py normal m`:%s/\s\+$//e ``
" Auto Indent
autocmd BufRead *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class

"" Detect django models file
if getline(1) =~ 'from django.db import models'
    runtime! ftplugin/django_model_snippets.vim
endif 

"" Remember last position in file
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g'\"" | endif

"" NERD_tree config
" let NERDTreeChDirMode=2
" let NERDTreeIgnore=['\.vim$', '\~$', '\.pyc$', '\.swp$']
" let NERDTreeSortOrder=['^__\.py$', '\/$', '*', '\.swp$', '\.bak$', '\~$']
" let NERDTreeShowBookmarks=1
set tags=tags;$HOME/.vim/tags/ "recursively searches directory for 'tags' file

"" TagList Plugin Configuration
let Tlist_Ctags_Cmd='/usr/bin/ctags' " point taglist to ctags
let Tlist_Exit_OnlyWindow = 1 " Close vim when only taglist window left
let Tlist_File_Fold_Auto_Close = 1 " Close folds for inactive files
let Tlist_Auto_Highlight_Tag = 1 " Automatically highlight the current tag
let Tlist_Auto_Open = 1 " Auto open taglist
let Tlist_Auto_Update = 1
let Tlist_Display_Tag_Scope = 1
let Tlist_Enable_Fold_Column = 1
let Tlist_File_Fold_Auto_Close = 1 " Close for inactive buffers
let Tlist_Highlight_Tag_On_BufEnter = 0 " Don't highlight on buffer enter
let Tlist_GainFocus_On_ToggleOpen = 0 " Focus on the taglist when its toggled
let Tlist_Show_Menu = 1 " Show menu for taglist

"" TaskList
" autocmd BufWinEnter * silent :TaskList

"" Show recent files when opening vim
" autocmd BufWinEnter * :MRU
argdo let file_specified=1
if !exists('file_specified')
    autocmd VimEnter * :MRU
endif

"
" map <F3> :NERDTreeToggle<CR>
" map <F4> :TlistToggle<CR>
" map <F2> :marks 

"" Add workpath to python
python << EOF
import os
import sys
import vim
sys.path.append("/opt")
sys.path.append("/opt/xanview")
EOF
