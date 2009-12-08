" File:        AutoFenc.vim
" Brief:       Tries to automatically detect file encoding
" Author:      Petr Zemek, s3rvac AT gmail DOT com
" Version:     1.1.1
" Last Change: Sat Oct  3 21:23:02 CEST 2009
"
" License:
"   Copyright (C) 2009 Petr Zemek
"   This program is free software; you can redistribute it and/or modify it
"   under the terms of the GNU General Public License as published by the Free
"   Software Foundation; either version 2 of the License, or (at your option)
"   any later version.
"
"   This program is distributed in the hope that it will be useful, but
"   WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
"   or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
"   for more details.
"
"   You should have received a copy of the GNU General Public License along
"   with this program; if not, write to the Free Software Foundation, Inc.,
"   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
"
" Description:
"   This script tries to automatically detect and set file encoding when
"   opening a file in Vim. It does this in several possible ways (according
"   to the configuration) in this order (when a method fails, it tries
"   the following one):
"     (1) detection of BOM (byte-order-mark) at the beginning of the file,
"         only for some multibyte encodings
"     (2) HTML way of encoding detection (via <meta> tag), only for HTML based
"         file types
"     (3) XML way of encoding detection (via <?xml ... ?> declaration), only
"         for XML based file types
"     (4) CSS way of encoding detection (via @chardet 'at-rule'), only for
"         CSS files
"     (5) checks whether the encoding is specified in a comment (like
"         '# Encoding: latin2'), for all file types
"     (6) tries to detect the encoding via specified external program
"         (the default one is enca), for all file types
"
"   If the autodetection fails, it's up to Vim (and your configuration)
"   to set the encoding.
"
"   Configuration options for this plugin (you can set them in your $HOME/.vimrc):
"    - g:autofenc_enable (0 or 1, default 1)
"        Enables/disables this plugin.
"    - g:autofenc_max_file_size (number >= 0, default 10485760)
"        If the size of a file is higher than this value (in bytes), then
"        the autodetection will not be performed.
"    - g:autofenc_disable_for_files_matching (regular expression, see below)
"        If the file (with complete path) matches this regular expression,
"        then the autodetection will not be performed. It is by default set
"        to disable autodetection for non-local files (e.g. accessed via ftp,
"        scp etc., because the script can't handle some kind of autodetection
"        for these files). The regular expression is matched case-sensitively.
"    - g:autofenc_disable_for_file_types (list of strings, default [])
"        If the file type matches some of the filetypes specified in this list,
"        then the autodetection will not be performed. Comparison is done
"        case-sensitively.
"    - g:autofenc_autodetect_bom (0 or 1, default 1)
"        Enables/disables detection of encoding by BOM.
"    - g:autofenc_autodetect_html (0 or 1, default 1)
"        Enables/disables detection of encoding for HTML based documents.
"    - g:autofenc_autodetect_xml (0 or 1, default 1)
"        Enables/disables detection of encoding for XML based documents.
"    - g:autofenc_autodetect_css (0 or 1, default 1)
"        Enables/disables detection of encoding for CSS documents.
"    - g:autofenc_autodetect_comment (0 or 1, default 1)
"        Enables/disables detection of encoding in comments.
"    - g:autofenc_autodetect_comment_num_of_lines (number >= 0, default 5)
"        How many lines from the beginning and from the end of the file should
"        be searched for the possible encoding declaration
"    - g:autofenc_autodetect_ext_prog (0 or 1, default 1)
"        Enables/disables detection of encoding via external program
"        (see additional settings below).
"    - g:autofenc_ext_prog_path (string, default 'enca')
"        Path to the external program. It can be either relative or absolute.
"        The external program can take any number of arguments, but
"        the last one must be a path to the file for which the encoding
"        is to be detected (it will be supplied by this plugin).
"        Output of the program must be the name of encoding in which the file
"        is saved (string on a single line).
"    - g:autofenc_ext_prog_args (string, default '-i -L czech')
"        Additional program arguments (can be none, i.e. '').
"    - g:autofenc_ext_prog_unknown_fenc (string, default '???')
"        If the output of the external program is this string, then it means
"        that the file encoding was not detected successfully. The string must
"        be case-sensitive.
"
" Requirements:
"   - filetype plugin must be enabled (a line like 'filetype plugin on' must
"     be in your $HOME/.vimrc [*nix] or %UserProfile%\_vimrc [MS Windows])
"
" Installation Details:
"   Put this file into your $HOME/.vim/plugin directory [*nix]
"   or %UserProfile%\vimfiles\plugin folder [MS Windows].
"
" Notes:
"  This script is by all means NOT perfect, but it works for me and suits my
"  needs very well, so it might be also useful for you. Your feedback,
"  opinion, suggestions, bug reports, patches, simply anything you have
"  to say is welcomed!
"
"  There are two similar plugins to this one, so if you don't like this one,
"  you can test these:
"    - FencView.vim (http://www.vim.org/scripts/script.php?script_id=1708)
"        Mainly supports detection of encodings for asian languages.
"    - MultiEnc.vim (http://www.vim.org/scripts/script.php?script_id=1806)
"        Obsolete, merged with the previous one.
"  Let me know if there are others and I'll add them here.
"
" Changelog:
"   1.1.1 (2009-10-03)
"     - Fixed the comment encoding detection function (the encoding was not
"       detected if there were some alphanumeric characters before
"       the "encoding" string, like in "# vim:fileencoding=<encoding-name>").
"
"   1.1 (2009-08-16)
"     - Added three configuration possibilites to disable autodetection for
"       specific files (based on file size, file type and file path).
"       See script description for more info.
"
"   1.0.2 (2009-08-11)
"     - Fixed the XML encoding detection function.
"     - Minor code and documentation fixes.
"
"   1.0.1 (2009-08-02)
"     - Encoding autodetection is now performed only if the opened file
"       exists (is stored somewhere). So, for example, the autodetection
"       is now not performed when a new file is opened.
"     - Correctly works with .viminfo, where the last cursor position
"       in the file is stored when exiting the file. In the previous version
"       of this script, this information was sometimes ignored and the cursor
"       was initially on the very last line in a file. If the user does not
"       use this .viminfo feature (or he does not use .viminfo at all),
"       then the cursor will be initially placed on the very first line.
"     - (Hopefully) fixed the implementation of the function which sets
"       the detected encoding.
"
"   1.0 (2009-07-26)
"     - Initial release version of this script.
"

" Check if the plugin was already loaded
if exists('autofenc_loaded')
	finish
endif
let autofenc_loaded = 1

"-------------------------------------------------------------------------------
" Checks whether the selected variable (first parameter) is already set and
" if not, it sets it to the value of the second parameter.
"-------------------------------------------------------------------------------
function s:CheckAndSetVar(var, value)
	if !exists(a:var)
		exec 'let ' . a:var . ' = ' . string(a:value)
	endif
endfunction

" Variables initialization (see script description for more information)
call s:CheckAndSetVar('g:autofenc_enable', 1)
call s:CheckAndSetVar('g:autofenc_max_file_size', 10485760)
call s:CheckAndSetVar('g:autofenc_disable_for_files_matching', '^[-_a-zA-Z0-9]\+://')
call s:CheckAndSetVar('g:autofenc_disable_for_file_types', [])
call s:CheckAndSetVar('g:autofenc_autodetect_bom', 1)
call s:CheckAndSetVar('g:autofenc_autodetect_html', 1)
call s:CheckAndSetVar('g:autofenc_autodetect_xml', 1)
call s:CheckAndSetVar('g:autofenc_autodetect_css', 1)
call s:CheckAndSetVar('g:autofenc_autodetect_comment', 1)
call s:CheckAndSetVar('g:autofenc_autodetect_comment_num_of_lines', 5)
call s:CheckAndSetVar('g:autofenc_autodetect_ext_prog', 1)
call s:CheckAndSetVar('g:autofenc_ext_prog_path', 'enca')
call s:CheckAndSetVar('g:autofenc_ext_prog_args', '-i -L czech')
call s:CheckAndSetVar('g:autofenc_ext_prog_unknown_fenc', '???')

"-------------------------------------------------------------------------------
" Normalizes selected encoding and returns it, so it can be safely used as
" a new encoding. This function should be called before a new encoding is set.
"-------------------------------------------------------------------------------
function s:NormalizeEncoding(enc)
	let nenc = tolower(a:enc)

	" Some canonical encoding names in Vim
	if nenc =~ 'iso[-_]8859-1'
		return 'latin1'
	elseif nenc =~ 'iso[-_]8859-2'
		return 'latin2'
	elseif nenc =~ '\(cp\|win\(dows\)\?\)-1250'
		return 'cp1250'
	elseif nenc == 'utf8'
		return 'utf-8'
	endif

	return nenc
endfunction

"-------------------------------------------------------------------------------
" Sets the selected file encoding. Returns 1 if the file was reloaded,
" 0 otherwise.
"-------------------------------------------------------------------------------
function s:SetFileEncoding(enc)
	let nenc = s:NormalizeEncoding(a:enc)

	" Check whether we're not trying to set current file encoding
	if nenc !=? &fenc
		" Backup the original fencs and syntax highlighting (it is forgotten when
		" the file is reloaded)
		let old_fencs = &fencs
		let old_syntax = &syntax

		" Set the file encoding and reload it
		exec 'set fencs='.nenc
		exec 'edit'

		" Reset fenc syntax highlighting to their original values
		let &fencs = old_fencs
		let &syntax = old_syntax

		" File was reloaded
		return 1
	else
		" File was not reloaded
		return 0
	endif
endfunction

"-------------------------------------------------------------------------------
" Tries to detect a BOM (byte order mark) at the beginning of the file to
" detect a multibyte encoding. If there is a BOM, it returns the appropriate
" encoding, otherwise the empty string is returned.
"-------------------------------------------------------------------------------
function s:BOMEncodingDetection()
	" Implementation of this function is based on a part of the FencsView.vim
	" plugin by Ming Bai (http://www.vim.org/scripts/script.php?script_id=1708)

	" Get the first line of the file
	let file_content = readfile(expand('%:p'), 'b', 1)
	if file_content == []
		" Empty file
		return ''
	endif
	let first_line = file_content[0]

	" Check whether it contains BOM and if so, return appropriate encoding
	" Note: If the index is out of bounds, ahx is set to '' automatically
	let ah1 = first_line[0]
	let ah2 = first_line[1]
	let ah3 = first_line[2]
	let ah4 = first_line[3]
	" TODO: I don't know why but if there is a NUL byte, the char2nr()
	" function transforms it to a newline (0x0A) instead of 0x00...
	let a1  = char2nr(ah1) == 0x0A ? 0x00 : char2nr(ah1)
	let a2  = char2nr(ah2) == 0x0A ? 0x00 : char2nr(ah2)
	let a3  = char2nr(ah3) == 0x0A ? 0x00 : char2nr(ah3)
	let a4  = char2nr(ah4) == 0x0A ? 0x00 : char2nr(ah4)
	if a1.a2.a3.a4 == 0x00.0x00.0xfe.0xff
		return 'utf-32'
	elseif a1.a2.a3.a4 == 0xff.0xfe.0x00.0x00
		return 'utf-32le'
	elseif a1.a2.a3 == 0xef.0xbb.0xbf
		return 'utf-8'
	elseif a1.a2 == 0xfe.0xff
		return 'utf-16'
	elseif a1.a2 == 0xff.0xfe
		return 'utf-16le'
	endif

	" There was no legal BOM
	return ''
endfunction

"-------------------------------------------------------------------------------
" Tries the HTML way of encoding detection of the current file and returns the
" detected encoding (or the empty string, if the encoding was not detected).
"-------------------------------------------------------------------------------
function s:HTMLEncodingDetection()
	" This method is based on the meta tag in the head of the HTML document
	" (<meta http-equiv="Content-Type" ...)

	" Store the actual position in the file and move to the very first line
	" in the file
	normal m`
	normal gg

	let enc = ''

	" The following regexp is a modified version of the regexp found here:
	" http://vim.wikia.com/wiki/Detect_encoding_from_the_charset_specified_in_HTML_files
	if search('\c<meta\s\+http-equiv=\("\?\)Content-Type\1\s\+content="[A-Za-z]\+/[+A-Za-z]\+;\s\+charset=[-A-Za-z0-9_]\+"') != 0
		let enc = matchstr(getline('.'), 'charset=\zs[-A-Za-z0-9_]\+')
	endif

	" Restore the original position in the file
	normal ``

	return enc
endfunction

"-------------------------------------------------------------------------------
" Tries the XML way of encoding detection of the current file and returns the
" detected encoding (or the empty string, if the encoding was not detected).
"-------------------------------------------------------------------------------
function s:XMLEncodingDetection()
	" The first part of this method is based on the first line of XML files
	" (<?xml version="..." encoding="..."?>)

	" Store the actual position in the file and move to the very first line
	" in the file
	normal m`
	normal gg

	let enc = ''

	if search('\c<?xml\s\+version="[.0-9]\+"\s\+encoding="[-A-Za-z0-9_]\+"') != 0
		let enc = matchstr(getline('.'), 'encoding="\zs[-A-Za-z0-9_]\+')
	endif

	" Restore the original position in the file
	normal ``

	" If there was no encoding specified, return utf-8 (the check for BOM
	" should be done in another function - if the user wish that)
	return enc != '' ? enc : 'utf-8'
endfunction

"-------------------------------------------------------------------------------
" Tries the CSS way of encoding detection of the current file and returns the
" detected encoding (or the empty string, if the encoding was not detected).
"-------------------------------------------------------------------------------
function s:CSSEncodingDetection()
	" This method is based on the @charset 'at-rule'
	" (see http://www.w3.org/International/questions/qa-css-charset)

	" Store the actual position in the file and move to the very first line
	" in the file
	normal m`
	normal gg

	let enc = ''

	" Note: The specs says that this line should be the first line in the file,
	" but I'm searching every line in the file (some comments could perhaps
	" precede the @charset in practice). If you don't like it, you are
	" encouraged to change the code :).
	if search('\c^\s*@charset\s\+"[-A-Za-z0-9_]\+"') != 0
		let enc = matchstr(getline('.'), '^\s*@charset\s\+"\zs[-A-Za-z0-9_]\+')
	endif

	" Restore the original position in the file
	normal ``

	return enc
endfunction

"-------------------------------------------------------------------------------
" Tries to detect encoding via encoding specified in a comment. The file is
" searched for a line like '# encoding: utf-8' and the file encoding is
" returned according to this line. If there is no such line, the empty string
" is returned.
"
" Currently, the format of the comment that specifies encoding is some
" non-alphabetic characters at the beginning of the line, then 'coding'
" or 'encoding' (without quotes, case insensitive), which is followed by
" optional ':' (and whitespace) and the name of the encoding.
"-------------------------------------------------------------------------------
function s:CommentEncodingDetection()
	" Get first and last X lines from the file (according to the configuration)
	let num_of_lines = g:autofenc_autodetect_comment_num_of_lines
	let lines_to_search_enc = readfile(expand('%:p'), '', num_of_lines)
	let lines_to_search_enc += readfile(expand('%:p'), '', -num_of_lines)

	" Check all of the returned lines
	let re = '\c^\A.*\(en\)\?coding[:=]\?\s*\zs[-A-Za-z0-9_]\+'
	for line in lines_to_search_enc
		let enc = matchstr(line, re)
		if enc != ''
			return enc
		endif
	endfor

	return ''
endfunction

"-------------------------------------------------------------------------------
" Tries to detect the file encoding via selected external program.
" If the program is not executable or there is some error, it returns
" the empty string. Otherwise, the detected encoding is returned.
"-------------------------------------------------------------------------------
function s:ExtProgEncodingDetection()
	if executable(g:autofenc_ext_prog_path)
		" Get full path of the currently edited file
		let file_path = expand('%:p')

		" Transform it so it can be passed to the enca program as an argument
		" (in quotes, because there can be spaces in the file path)
		let quoted_fp = substitute(file_path, '"', '\\"', 'g')

		" Create the complete external program command by appending program
		" arguments and the current file path to the external program
		let ext_prog_cmd = g:autofenc_ext_prog_path.' '.g:autofenc_ext_prog_args.' "'.quoted_fp.'"'

		" Run it to get the encoding
		let enc = system(ext_prog_cmd)

		" Remove trailing newline from the output
		" (system() removes any \r from the result automatically)
		let enc = substitute(enc, '\n', '', '')

		if enc != g:autofenc_ext_prog_unknown_fenc
			" Encoding was (probably) detected successfully
			return enc
		endif
	endif

	return ''
endfunction

"-------------------------------------------------------------------------------
" Tries to detect encoding of the current file via several ways (according
" to the configuration) and returns it. If the encoding was not detected
" successfully, it returns the empty string - this can happen because:
"  - the file is in unknown encoding
"  - the file is not stored anywhere (e.g. a new file was opened)
"  - autodetection is disabled for this file (either the file is too large
"    or autodetection is disabled for this file, see configuration)
"-------------------------------------------------------------------------------
function s:DetectFileEncoding()
	" Check whether the autodetection should be performed
	" (see function description for more information)
	let file_path = expand('%:p')
	let file_size = getfsize(file_path)
	if file_path == '' ||
			\ file_size > g:autofenc_max_file_size || file_size < 0 ||
			\ file_path =~ g:autofenc_disable_for_files_matching ||
			\ index(g:autofenc_disable_for_file_types, &ft, 0, 1) != -1
		return ''
	endif

	" BOM encoding detection
	if g:autofenc_autodetect_bom
		let enc = s:BOMEncodingDetection()
		if enc != ''
			return enc
		endif
	endif

	" HTML encoding detection
	if g:autofenc_autodetect_html && &filetype =~ '\(html\|xhtml\)'
		let enc = s:HTMLEncodingDetection()
		if enc != ''
			return enc
		endif
	endif

	" XML encoding detection
	if g:autofenc_autodetect_xml && &filetype =~ '\(xml\|xsl\|xsd\)'
		let enc = s:XMLEncodingDetection()
		if enc != ''
			return enc
		endif
	endif

	" CSS encoding detection
	if g:autofenc_autodetect_css && &filetype =~ '\(css\)'
		let enc = s:CSSEncodingDetection()
		if enc != ''
			return enc
		endif
	endif

	" Comment encoding detection
	if g:autofenc_autodetect_comment
		let enc = s:CommentEncodingDetection()
		if enc != ''
			return enc
		endif
	endif

	" External program encoding detection
	if g:autofenc_autodetect_ext_prog
		let enc = s:ExtProgEncodingDetection()
		if enc != ''
			return enc
		endif
	endif

	" Encoding was not detected
	return ''
endfunction

"-------------------------------------------------------------------------------
" Main plugin function. Tries to autodetect the correct file encoding
" and sets the detected one (if any). If the ASCII encoding is detected,
" it does nothing to allow Vim to set it's internal encoding instead.
"-------------------------------------------------------------------------------
function s:DetectAndSetFileEncoding()
	let enc = s:DetectFileEncoding()

	if (enc != '') && (enc != 'ascii')
		let file_reloaded = s:SetFileEncoding(enc)
	endif
endfunction

" Set the detected file encoding
if g:autofenc_enable
	au BufRead * call s:DetectAndSetFileEncoding()
endif
