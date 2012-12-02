" File:        khuno.vim
" Description: A Python Flakes plugin: analyze your code on the fly
" Maintainer:  Alfredo Deza <alfredodeza AT gmail.com>
" License:     MIT
" Notes:       The (current) alternatives forced you to call a function. We
"              can do better. This plugin is better.
"
"============================================================================


if exists("g:loaded_khuno") || &cp
  finish
endif


let g:loaded_khuno = 1


if !exists('g:khuno_flake_cmd')
  let g:khuno_flake_cmd = 'flake8'
endif


function! s:KhunoDebugSyntax() abort
  let b:current_syntax = 'khunoDebug'
  syn match KhunoKeys                 "\v^(Temp file|Command|Error file)\s+"
  syn match KhunoTitle                '\v^Khuno(.*)$'
  syn match KhunoDelimiter            '\v(\=\=\>)'

  hi def link KhunoKeys               String
  hi def link KhunoTitle              String
  hi def link KhunoDelimiter          Comment
endfunction


function! s:KhunoErrorSyntax() abort
  let b:current_syntax = 'khunoErrors'
  syn match KhunoDelimiter            "\v\s+(\=\=\>)\s+"
  syn match KhunoLine                 "Line:"
  syn match KhunoColumn               "\v\s+Col:\s+"

  hi def link KhunoDelimiter          Comment
  hi def link KhunoLine               String
  hi def link KhunoColumn             String
endfunction


function! s:GoToInlineError(direction)
  "  Goes to the current open window that matches
  "  the error path and moves you there. Pretty awesome
  let text = getline('.')
  echo text
  if !len(text)
    return
  endif
  let line_number = matchlist(text, '\v^(Line:\s+)(\d+)')[2]
  let column_number = matchlist(text, '\v\s+(Col:\s+)(\d+)')[2]

  " Go to previous window
  exe 'wincmd p'
  execute line_number
  execute 'normal! zz'
  execute 'normal! ' . column_number . '|h'
  exe 'wincmd p'
endfunction


" au commands
augroup khuno_automagic
  autocmd!
  autocmd BufEnter * if s:au_should_run() | call s:Flake() | endif
  autocmd BufWritePost * if s:au_should_run() | call s:Flake() | endif
  autocmd InsertLeave <buffer> if s:au_should_run() | call s:Flake() | endif
  autocmd InsertLeave * if s:au_should_run() | call  s:ParseReport() | endif
augroup END

au CursorMoved * if &ft ==# 'python' | call  s:GetFlakesMessage() | endif
au CursorMoved * if &ft ==# 'python' | call  s:ParseReport() | endif


function! s:au_should_run() abort
  if !exists('b:khuno_au_enabled')
    let b:khuno_au_enabled = 1
  endif
  if ((&ft ==# 'python') && (b:khuno_au_enabled))
    return 1
  endif
  return 0
endfunction


function! s:KhunoAutomagic(enabled)
  if a:enabled
    augroup khuno_automagic
    else
      au! khuno_automagic
    endif
endfunction


function! s:Echo(msg, ...)
  redraw
  let x=&ruler | let y=&showcmd
  set noruler noshowcmd
  if (a:0 == 1)
    echo a:msg
  else
    echohl WarningMsg | echo a:msg | echohl None
  endif

  let &ruler=x | let &showcmd=y
endfunction


if exists('g:khuno_automagic')
  if (g:khuno_automagic > 0)
    call s:KhunoAutomagic(1)
  else
    call s:KhunoAutomagic(0)
  endif
else
  call s:KhunoAutomagic(1)
endif


function! s:ClearAll(...)
  let current = winnr()
  let bufferL = ['Errors.khuno', 'Debug.khuno']
  for b in bufferL
    let _window = bufwinnr(b)
    if (_window != -1)
      silent! execute _window . 'wincmd w'
      silent! execute 'q'
    endif
  endfor

  " Remove any echoed messages
  if (a:0 == 1)
    " Try going back to our starting window
    " and remove any left messages
    call s:Echo('')
    silent! execute 'wincmd p'
  else
    execute current . 'wincmd w'
  endif
endfunction


function! s:ToggleErrorWindow()
  let winnr = bufwinnr('Errors.khuno')
  if (winnr == -1)
    call s:MakeErrorWindow()
  else
    silent! execute winnr . 'wincmd w'
    silent! execute 'q'
    silent! execute 'wincmd p'
  endif
endfunction


function! s:MakeDebugWindow() abort
  if !exists('b:khuno_debug')
    call s:Echo("khuno: no debug information available.")
    return
  endif
  let s:debug = b:khuno_debug
  let s:error_file = b:khuno_error_files[-1]
  call s:ClearAll()
  let winnr = bufwinnr('Debug.khuno')
  silent! execute  winnr < 0 ? 'botright new ' . 'Debug.khuno' : winnr . 'wincmd w'
  setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile nowrap number filetype=khuno
  let error_number = 1
  call setline(1, "Khuno debug information:")
  execute 'normal o'. 'Temp file  ==> ' . s:debug['temp_file']
  execute 'normal o'. 'Command    ==> ' . s:debug['cmd']
  execute 'normal o'. 'Error file ==> ' . s:debug['temp_error']
  if filereadable(s:error_file) && len(readfile(s:error_file))
    execute 'normal o'. 'Errors from command show below:'
    for line in readfile(s:error_file)
      execute 'normal o' . line
    endfor
  endif
  if (line('$') > 10)
    let resize = 10
  else
    let resize = line('$')
  endif
  silent! execute 'resize ' . resize
  autocmd! BufEnter Debug.khuno call s:CloseIfLastWindow()
  nnoremap <silent> <buffer> q       :call <sid>ClearAll(1)<CR>
  nnoremap <silent> <buffer> <Enter> :call <sid>ClearAll(1)<CR>
  exe 1
  exe "normal! 0|h"
  call s:Echo("Hit q or Enter to exit", 1)
  call s:KhunoDebugSyntax()
endfunction


function! s:MakeErrorWindow() abort
  let modified = &modified
  if !exists('b:flake_errors')
    call s:Echo("No flake errors from a previous run")
    return
  endif
  call s:ClearAll()
  " TODO revisit this at some point, redrawing makes the terminal
  " flicker
  "au BufLeave *.khuno echo "" | redraw!
  if (len(b:flake_errors) == 0)
    call s:Echo("No flake errors from a previous run")
    return
  endif
  let s:flake_errors = b:flake_errors
  let winnr = bufwinnr('Errors.khuno')
  silent! execute  winnr < 0 ? 'botright new ' . 'Errors.khuno' : winnr . 'wincmd w'
  setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile nowrap number filetype=khuno
  let error_number = 0
  for line_no in keys(s:flake_errors)
    if line_no != "last_error_line"
      let errors = s:flake_errors[line_no]
      for err in errors
        let error = err["error_text"]
        let column = err["error_column"]
        let message = printf('Line: %-*u Col: %-*u ==> %s', 3, line_no, 3, column, error)
        let error_number = error_number + 1
        call setline(error_number, message)
      endfor
    endif
  endfor
  execute "sort n"
  if (line('$') > 10)
    let resize = 10
  else
    let resize = line('$')
  endif
  silent! execute 'resize ' . resize
  autocmd! BufEnter Errors.khuno call s:CloseIfLastWindow()
  nnoremap <silent> <buffer> q       :call <sid>ClearAll(1)<CR>
  nnoremap <silent> <buffer> <Enter> :call <sid>GoToInlineError(1)<CR>
  call s:KhunoErrorSyntax()
  exe "normal! 0|h"
  if modified
    call s:Echo("Khuno has not updated yet, errors might be out of date. Hit q to exit")
  else
    call s:Echo("Hit q to exit", 1)
  endif
endfunction


function! s:Flake()
  if exists("g:khuno_builtins")
    let s:khuno_builtins_opt=" --builtins=".g:khuno_builtins
  else
    let s:khuno_builtins_opt=""
  endif

  if exists("g:khuno_ignore")
    let s:khuno_ignores=" --ignore=".g:khuno_ignore
  else
    let s:khuno_ignores=""
  endif

  if exists("g:khuno_max_line_length")
    let s:khuno_max_line_length=" --max-line-length=".g:khuno_max_line_length
  else
    let s:khuno_max_line_length=""
  endif

  let cmd=g:khuno_flake_cmd . s:khuno_builtins_opt . s:khuno_ignores . s:khuno_max_line_length

  " Write to a temp path so that unmodified contents are parsed
  " correctly, regardless.
  let tmp_path = tempname()
  silent! execute "w " . tmp_path
  let cmd = cmd . " ". tmp_path
  call s:AsyncCmd(cmd)
endfunction


function! s:ParseReport()
  if !exists('b:khuno_called_async')
    return
  endif
  if (b:khuno_called_async == 0)
    return
  endif

  " Parse stderr first, then try stdout
  if s:has_invalid_syntax()
    let errors = s:ReadOutput(b:khuno_debug['temp_error'])
  else
    let errors = s:ReadOutput(b:khuno_debug['temp_file'])
  endif

  silent! call s:ClearFlakes()
  let b:flake_errors = errors
  if len(errors)
    call s:ShowErrors()
  endif
endfunction


function! s:ReadOutput(file)
  " Output can be a stdout file or a stderr
  " so we make sure we can parse any of them here
  " to prevent not showing anything in case we have a syntax error
  " that makes the checker to blow up.
  " typical line expected from a report:
  " some_file.py:107:80: E501 line too long (86 > 79 characters)
  let line_regex = '\v^(.*):(\d+):'
  let errors = {}
  for line in readfile(a:file)
    if line =~ line_regex
      let current_error = {}
      let error_line = matchlist(line, '\v:(\d+):')[1]
      let has_error_column = matchlist(line, '\v:(\d+):(\d+):')
      if (has_error_column != [])
        let current_error.error_column = has_error_column[2]
      else
        let current_error.error_column = 0
      endif
      let current_error.error_text = matchlist(line, '\v(\d+):\s+(.*)')[2]

      " Lets see if we need to append to an existing line or not
      if has_key(errors, error_line)
        call add(errors[error_line], current_error)
      else
        let errors[error_line] = [current_error]
      endif
      let errors.last_error_line = error_line
    endif
  endfor
  return errors
endfunction


function! s:has_invalid_syntax()
  " This will only be called from s:ParseReport, so no effort into
  " check all the buffer flags
  if !exists('b:khuno_error_files')
    return 0
  endif
  let err_file = b:khuno_error_files[-1]
  if !filereadable(err_file)
    return 0
  else
    for line in readfile(err_file)
      if line =~ '\v\s+invalid\s+syntax'
        return 1
      endif
    endfor
    return 0
  endif
endfunction



function! s:ShowErrors() abort
  highlight link Flakes SpellBad
  for line in keys(b:flake_errors)
    if line != "last_error_line"
      let err = b:flake_errors[line][0]
      if (err['error_column'] > 0)
        if err['error_text'] =~ '\v\s+(line|trailing whitespace)'
          let match = '\%' . line . 'l\n\@!'
        else
          let match = '^\%'. line . 'l\_.\{-}\zs\k\+\k\@!\%>' . err['error_column'] . 'c'
        endif
        call matchadd('Flakes', match)
      else
        call matchadd('Flakes', '\%' . line . 'l\n\@!')
      endif
    endif
  endfor
  let b:khuno_called_async = 0
endfunction


function! s:CloseIfLastWindow()
  if winnr("$") == 1
    q
  endif
endfunction


function! s:ClearFlakes() abort
  let s:matches = getmatches()
  for s:matchId in s:matches
    if s:matchId['group'] == 'Flakes'
      call matchdelete(s:matchId['id'])
    endif
  endfor
  let b:flake_errors = {}
endfunction


function! s:GetFlakesMessage() abort
  if !(exists('b:flake_errors'))
    return
  endif
  let s:cursorPos = getpos(".")
  let line_no = s:cursorPos[1]
  " if there's a message for the line the cursor is currently on, echo
  " it to the console
  if has_key(b:flake_errors, line_no)
    call s:Echo(b:flake_errors[line_no][0]['error_text'])
  else
    echo
  endif
endfunction


function! s:AsyncCmd(cmd)
  if !exists('b:khuno_error_files')
    let b:khuno_error_files = []
  endif
  let s:khuno_temp_file = tempname()
  let s:khuno_temp_error_file = tempname()
  let command = "! " . a:cmd . " > " . s:khuno_temp_file . " 2> " . s:khuno_temp_error_file . " &"
  silent execute command
  let b:khuno_called_async = 1
  let b:khuno_debug = {}
  let b:khuno_debug.temp_file = s:khuno_temp_file
  let b:khuno_debug.temp_error = s:khuno_temp_error_file
  let b:khuno_debug.cmd = command
  call add(b:khuno_error_files, s:khuno_temp_error_file)
endfunction


function! s:Completion(ArgLead, CmdLine, CursorPos)
  let _version    = "version\n"
  let actionables = "run\nshow\nread\ndebug\n"
  let toggle = "on\noff\n"
  return _version . actionables . toggle
endfunction


function! s:Version()
  call s:Echo("khuno.vim version 0.0.1", 1)
endfunction


function! s:Proxy(action)
  if (executable(g:khuno_flake_cmd) == 0)
    call s:Echo("flake8 not found. This plugin needs flake8 installed and accessible")
    return
  endif
  if (a:action == "version")
    call s:Version()
  elseif (a:action == "run")
    call s:Flake()
  elseif (a:action == "show")
    call s:ToggleErrorWindow()
  elseif (a:action == "read")
    call s:ParseReport()
  elseif (a:action == "debug")
    call s:MakeDebugWindow()
  elseif (a:action == "on")
    let b:khuno_au_enabled = 1
  elseif (a:action == "off")
    call s:ClearFlakes()
    let b:khuno_au_enabled = 0
  else
    call s:Echo("Khuno: not a valid file or option ==> " . a:action)
  endif
endfunction


command! -nargs=+ -complete=custom,s:Completion Khuno call s:Proxy(<f-args>)
