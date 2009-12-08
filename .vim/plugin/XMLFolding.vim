" About XMLFolding Script                                                  {{{

" XMLFolding version 1.1 - May 13th, 2006
" Author: Thadeu Aparecido Coelho de Paula
" E-mail: thadeudepaula@gmail.com
" WebPage: http://mundolivre.hostrixonline.com
" 
" This is my first vim script... at this point I already worked three
" continual weeks to make it. Never give up your objectives!
" I hope that you enjoy it, and use it to accomplish your projects!
"
" This script is under GNU Public License... use it, change it, sell it but 
" never forget to mention the original author"
"
" Made using Vim 6.04 on Debian GNU/Linux
"
" This Script supports:
"
" Folding of comments "<!-- -->"
" Folding of open/close tags in different lines "<> </>"
" Folding between CDATA markers "<![CDATA[" and "]]>"

" }}}

" Howto                                                                    {{{

   " Installing                                                            {{{
" Copy this file for any location yow want to... I suggest that you put it on
" your ~/.vim/plugin directory.
"
" To load this script in your vim session, type on normal mode:
" :so ~/.vim/script/XMLFolding.vim
" (If you saved on local where I suggested!)

"}}}

   " How to load this script automaticaly?                                 {{{
"You can use this script more easily configuring your vim to run it on start...
"You'll need to put this line in your /etc/vim/vimrc or ~/.vimrc:

" au BufNewFile,BufRead *.xml,*.htm,*.html so ~/.vim/plugin/XMLFolding.vim

" The "*.xml,*.html" can be changed for the file extensions that you want to
" use with this script.
   "}}}

   " Limitatios... i.e, when the fold won't occurs                         {{{

" The syntax need to be perfectly to match correctly... the tags needs to be
" nested correctly...
" All the tags nested in the same line will not be folded... like this:
" 
" <start>blablabla<middle>blablabla</middle>asdsad
" </start>
"
" In this example only "start" will be folded...
"
" An other problem will occur when you end the line closing a tag different
" than the open tag that starts the line, because the matches ignore the lines
" that starts opening a tag and ends closing a tag...
"
" <start><middle>asdasdsd</middle>
" </start>
"
" This will cause an error, because MATCHES ARE NOT MADE BY THE CONTENT OF A
" TAG, but by the presence of start and end aspect: <----> </----> independent
" of the tag content... if it encounter an incorrect nesting, the folding for
" the document will be broken. 
"
" This way, the script serves as an validator, limited but functional!
 
   "}}}


"}}}

" Folding def commands                                                     {{{

   " Basic vim commands for folding definition                             {{{
syn sync fromstart
set foldmethod=syntax
   "}}}

   " Matches and regions                                                   {{{

syn region XMLFold start=+^<\([^/?!><]*[^/]>\)\&.*\(<\1\|[[:alnum:]]\)$+ end=+^</.*[^-?]>$+ fold transparent keepend extend

syn match XMLCData "<!\[CDATA\[\_.\{-}\]\]>" fold transparent extend

syn match XMLCommentFold "<!--\_.\{-}-->" fold transparent extend


   "}}}

   " Label shown for folded lines                                          {{{
set foldtext=XMLFoldLabel()
 fun! XMLFoldLabel()
  let getcontent = substitute(getline(v:foldstart), "^[[:space:]]*", "", 'g')
	let linestart = substitute(v:folddashes, ".", '»', 'g')
	return linestart . " " . getcontent
endfunction

   "}}}

"}}}
