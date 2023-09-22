" Constants {{{1

let $CODE='$HOME/git'

" Max Number of Records to show in QF/Location Lists
let g:maxQFlistRecords = 8
let g:qfListHeight = 5

" Fold marker string used through vimrc file without messing up folding
let g:fold_marker_string = '{'. '{'. '{'

" By default, don't close term after <leader>rr
" This can be toggled
let g:term_close = ''

" Enable/disable prepending jira issue in git commit message
let g:vira_commit_text_enable = ''

" Vim home directory
if has("unix")
    let vimHomeDir = $HOME . '/.vim'
else
    let vimHomeDir = $HOME . '/vimfiles'
endif

if has('mac')
  let g:python3_host_prog='/usr/bin/python3'
else
  let g:python3_host_prog='/usr/bin/python'
endif

" Functions {{{1

function! s:getExitStatus() abort " {{{2
  " Get the exit status from a terminal buffer by looking for a line near the end
  " of the buffer with the format, '[Process exited ?]'.
  let ln = line('$')
  " The terminal buffer includes several empty lines after the 'Process exited'
  " line that need to be skipped over.
  while ln >= 1
    let l = getline(ln)
    let ln -= 1
    let exitCode = substitute(l, '^\[Process exited \([0-9]\+\)\]$', '\1', '')
    if l != '' && l == exitCode
      " The pattern did not match, and the line was not empty. It looks like
      " there is no process exit message in this buffer.
      break
    elseif exitCode != ''
      return str2nr(exitCode)
    endif
  endwhile
  throw 'Could not determine exit status for buffer, ' . expand('%')
endfunc

function! s:afterTermClose(...) abort
  " a:0 -> number of arguments
  " a:1 -> expected name of buffer (with Process exited message)
  " a:2 -> expected exit code (default is 0)
  " This is a hack to easily handle the situation where I switched focus away
  " from the terminal window
  if bufname('%') !~# a:1
    call AllClose()
    return
  endif

  if a:0 > 1
    let expected_code = a:2
  else
    let expected_code = 0
  end
  if s:getExitStatus() == expected_code
    bdelete!
  endif
endfunc

augroup MyNeoterm
  autocmd!
  " The line '[Process exited ?]' is appended to the terminal buffer after the
  " `TermClose` event. So we use a timer to wait a few milliseconds to read the
  " exit status. Setting the timer to 0 or 1 ms is not sufficient; 20 ms seems to work for me.
  autocmd TermClose * if (g:term_close == '++close') | call timer_start(20, { -> s:afterTermClose('/tmp/flow') }) | endif
  autocmd TermClose *bash\ ~/git/Linux/git/gap call timer_start(20, { -> s:afterTermClose('/git/Linux/git/gap') })
  " autocmd TermClose *bash\ ~/git/Linux/git/gap call timer_start(20, { -> s:afterTermClose('/git/Linux/git/gap', 1) })
augroup END

function! ALEOpenResults() " {{{2
  let l:bfnum = bufnr('')
  let l:items = ale#engine#GetLoclist(l:bfnum)
  call setqflist([], 'r', {'items': l:items, 'title': 'ALE results'})
  let g:qfListHeight = min([ g:maxQFlistRecords, len(getqflist()) ])
  exe 'top ' . g:qfListHeight . ' cwindow'
endfunction"

function! ALERunLint() " {{{2
  if empty(ale#engine#GetLoclist(bufnr('')))
    let b:ale_enabled = 1
    augroup ALEProgress
      autocmd!
      autocmd User ALELintPost call ALEOpenResults() | autocmd! ALEProgress
    augroup end
    call ale#Queue(0, 'lint_file')
  else
    call ALEOpenResults()
  endif
endfunction

function! AllClose() " {{{2
    " Close all loc lists, qf, preview and terminal windows
    Windofast lclose
    cclose
    pclose
    for bufname in ['^fugitive', '/tmp/flow', '~/git/Linux/git/gap', '~/git/Linux/config/mani.yaml']
      let buffers = join(filter(range(1, bufnr('$')), 'buflisted(v:val) && bufname(v:val) =~# bufname'), ' ')
      if trim(buffers) !=? ''
        silent! exe 'bdelete '. buffers
      endif
    endfor
endf

function! BufDo(command) " {{{2
    " Just like bufdo, but restore the current buffer when done.
    let currBuff=bufnr('%')
    silent! execute 'bufdo ' . a:command
    silent! execute 'buffer ' . currBuff
endfunction

function! CloseQuickFixWindow() " {{{2
    " If the window is quickfix, proceed
    if &buftype=="quickfix"
        " If this window is last on screen quit without warning
        if winbufnr(2) == -1
            quit!
        endif
    endif
endfunction

function! PromptAndComment(inline_comment, prompt_text, comment_prefix) " {{{2
    " Add inline comment and align with other inline comments

    " Prompt user for comment text
    let prompt = UserInput(a:prompt_text)

    " Abort the rest of the function if the user hit escape
    if (prompt == '') | return | endif

    " Temporarily disable auto-pairs wrapping so the comment delimiter doesn't repeat
    let b:autopairs_enabled = 0

    " Either inline comment or comment above current line
    let insert_command = (a:inline_comment) ? 'A ' : 'O'

    " Prepare execution script for adding commented line
    let exe_string = 'normal ' . insert_command . b:NERDCommenterDelims['left'] . ' ' . a:comment_prefix . prompt

    " Add inline comment (add right delimiter if it exists)
    if (b:NERDCommenterDelims['right'] != '')
        let exe_string .= ' ' . b:NERDCommenterDelims['right']
    endif

    " Add commented line to document
    exe exe_string

    " Re-enable auto-pairs
    let b:autopairs_enabled = 1

endfunction

function! ConvertWSLpath(path, ...) " {{{2
    " I tested this on path in quickfix list
    " nnoremap <leader>rp :execute 's@^[^\|]*\|@\=Con(submatch(0))@'<CR>

    " Aligns with wslpath.exe flags
    " -a    force result to absolute path format
    " -u    translate from a Windows path to a WSL path (default)
    " -w    translate from a WSL path to a Windows path
    " -m    translate from a WSL path to a Windows path, with ‘/’ instead of ‘\\’
    if a:0 > 0
        let flag = a:1
    else
        let flag = ""
    end

    " This is only necessary for location list parsing/converting
    let path = substitute(a:path, "|$", "", "")

    " Use wslpath utility to convert path
    let formattedPath = system('wslpath ' . flag . ' "' . path . '"')
    return substitute(formattedPath, "\n", "", "")

endfunction

function! EditCommonFile(filename) " {{{2
    " Open file in new teb
    let current_filename = expand('%:t')
    let openfilestring = 'tabedit ' . a:filename
    silent exec openfilestring
endfunction

function! Figlet(...) " {{{2
    " Print ascii art comment

    " Read figlet output into list
    let lines = systemlist('figlet ' . a:1)

    " Add comments to each lines
    call map(lines, {index, val -> trim(b:NERDCommenterDelims["left"] . " " . val . " " . b:NERDCommenterDelims["right"])})
    " call writefile(lines, expand("~/figlet.txt"))

    " Dump list on screen
    put=lines

endfunction

function! FindFunc(...) " {{{2

    " Move cursor to next pattern match
    if (a:2 == 'next')
        call search(a:1)
        FoldOpen
    endif

    " Save search string into window local var
    let w:searchStr=a:1

    " Record initial line number into "z
    let @z = '|' . line('.') . '|'

    " Clear quickfix list
    lexpr []

    " Put Results into QuickFix Window
    silent execute 'g/'.a:1.'/laddexpr expand("%") . ":" . line(".") . ":" . GetLastFoldString() . getline(".") '

    " Prepare location list height - minimum or record count and max allowable limit
    let w:locListHeight = min([ g:maxQFlistRecords, len(getloclist(0)) ])

    " If there are no matched records, return
    if !w:locListHeight
        lclose
        return
    endif

    " Open Loc List and limit the record number
    execute 'bot ' . w:locListHeight . 'lopen'

    " Update search register
    let @/=a:1

    " Find initial line in QuickFix list
    call search(@z)

    " Jump to that record
    exe "normal \<CR>"

    " Go to proper column number (rather than the beginning of the line)
    GoToMatchedColumn
endfunction

" FoldText {{{2
function! GetFoldStrings() " {{{3
    " Make the status string a list of all the folds
    " Iterate through each fold level and add fold string to list
    let foldStringList = []
    let i = 1
    while i <= foldlevel(".")
        " Append string to list
        call add(foldStringList, FormatFoldString(GetLastFoldLineNum(i)))
        let i += 1
    endwhile

    " Add each fold line to status string
    let statusString = ""
    for i in foldStringList
        let statusString = statusString."|".i
    endfor

    return statusString."|"
endfunction

function! GetLastFoldString() " {{{3
  " Get the text of the last fold if following conditions exist
  if (len(filter(split(execute(':scriptname'), "\n"), 'v:val =~? "vim-coiled-snake"')) > 0
     \ && &filetype ==# 'python')
     \ || &filetype ==# 'markdown'
     \ || &filetype ==# 'vim'
    let foldStr = FormatFoldString(GetLastFoldLineNum(foldlevel("."))) . "|$}{$"
  else
    let foldStr = ""
  endif
  return foldStr
endfunction

function! GetLastFoldLineNum(foldLvl) " {{{3
    " Search backwards for fold marker
    " Get the line number of last Fold

    " TODO-MB [191126] - Try with zN or whatever the restore fold command is

    normal zR
    normal mz
    normal [z
    let line = line('.')
    normal `z
    return line
endfunction

function! FormatFoldString(lineNum) " {{{3
    " Format fold string so it looks neat
    " Get the line string of the current fold and remove special chars
    let line = getline(a:lineNum)
    " Remove programming language specific words
    let line = RemoveFiletypeSpecific(line)
    " Remove special (comment related) characters and extra spaces
    let line = RemoveSpecialCharacters(line)
    return line
endfunction

function! RemoveSpecialCharacters(line) " {{{3
    " Remove special (comment related) characters and extra spaces
    " Characters: " # ; /* */ // <!-- --> g:fold_marker_string
    " Remove fold marker string and comment characters
    let text = substitute(a:line, g:fold_marker_string.'\d\=\|'.b:NERDCommenterDelims['left'].'\|'.b:NERDCommenterDelims['right'], '', 'g')
    " Replace 2 or more spaces with a single space
    let text = substitute(text, ' \{2,}', ' ', 'g')
    " Remove leading and trailing spaces
    let text = substitute(text, '^\s*\|\s*$', '', 'g')
    " Remove text between () in functions
    let text = substitute(text, '(\(.*\)', '()', 'g')
    " Add nice padding
    return " ".text." "
endfunction

function! RemoveFiletypeSpecific(line) " {{{3
    " Remove programming language specific words
    let text = a:line
    if (&ft=='python')
        let text = substitute(a:line, '\<def\>\|\<class\>', '', 'g')
    elseif  (&ft=='cs')
        let text = substitute(a:line, '\<static\>\|\<int\>\|\<float\>\|\<void\>\|\<string\>\|\<bool\>\|\<private\>\|\<public\>\s', '', 'g')
    elseif  (&ft=='vim')
        let text = substitute(a:line, '\<function\>!\s', '', 'g')
    elseif  (&ft=='markdown')
        let text = substitute(a:line, '#', '', 'g')
    elseif  (&ft=='javascript')
        let text = substitute(a:line, '=\|{\s', '', 'g')
    elseif  (&ft=='yaml')
        let text = substitute(a:line, ':', '', 'g')
    endif
    return text
endfunction
" FontSize() {{{2
if has("unix")
    function! FontSizePlus ()
        let l:gf_size_whole = matchstr(&guifont, '\( \)\@<=\d\+$')
        let l:gf_size_whole = l:gf_size_whole + 1
        let l:new_font_size = ' '.l:gf_size_whole
        let &guifont = substitute(&guifont, ' \d\+$', l:new_font_size, '')
    endfunction

    function! FontSizeMinus ()
        let l:gf_size_whole = matchstr(&guifont, '\( \)\@<=\d\+$')
        let l:gf_size_whole = l:gf_size_whole - 1
        let l:new_font_size = ' '.l:gf_size_whole
        let &guifont = substitute(&guifont, ' \d\+$', l:new_font_size, '')
    endfunction
else
    function! FontSizePlus ()
        let l:gf_size_whole = matchstr(&guifont, '\(:h\)\@<=\d\+$')
        let l:gf_size_whole = l:gf_size_whole + 1
        let l:new_font_size = ':h'.l:gf_size_whole
        let &guifont = substitute(&guifont, ':h\d\+$', l:new_font_size, '')
    endfunction

    function! FontSizeMinus ()
        let l:gf_size_whole = matchstr(&guifont, '\(:h\)\@<=\d\+$')
        let l:gf_size_whole = l:gf_size_whole - 1
        let l:new_font_size = ':h'.l:gf_size_whole
        let &guifont = substitute(&guifont, ':h\d\+$', l:new_font_size, '')
    endfunction
endif

function! GetBufferList() " {{{2
    " load all current buffers into a list
    redir =>buflist
    silent! ls!
    redir END
    return buflist
endfunction

function! GetTODOs() " {{{2
    " TODO [171103] - Add current file ONLY option
    " Binary files that can be ignored
    set wildignore+=*.jpg,*.docx,*.xlsm,*.mp4
    " Seacrch the CWD to find all of your current TODOs
    vimgrep /TODO-MB \[\d\{6}]/ **/* **/.* | cw 5
    " Un-ignore the binary files
    set wildignore-=*.jpg,*.docx,*.xlsm,*.mp4
endfunction

function! GitAddCommitPush() abort " {{{2
    " Git - add all, commit and push

    if g:vira_active_issue ==? 'none' || get(g:, 'vira_commit_text_enable', '') ==? ''
      let commit_text=''
    else
      let commit_text=g:vira_active_issue . ':'
    endif

    if has('unix') " Linux
        if has('nvim')
            exe 'sp term://bash ~/git/Linux/git/gap'
        else
            exe 'term ++close bash --login -c "export TERM=tmux-256color; '.$HOME.'/git/Linux/git/gap '.commit_text.'"'
        endif
    else " Windows
        exe '!"C:\Program Files\Git\usr\bin\bash.exe" ~/git/Linux/git/gap '.commit_text
    endif
    redraw!

endfunction

function! GitNewBranch() abort " {{{2
    " Create new git branch based on active vira issue

    if g:vira_active_issue ==? 'none'
      echom 'Please select issue first'
      return
    endif
    execute('Git checkout -b ' . g:vira_active_issue)
    Git push -u

endfunction

function! GitDeleteBranch() abort " {{{2
    " Delete branch for active vira issue

    if g:vira_active_issue ==? 'none'
      echom 'Please select issue first'
      return
    endif
    if g:vira_active_issue ==# FugitiveHead()
      echom 'Change branch first'
      return
    endif

    execute('Git branch -d ' . g:vira_active_issue)
    execute('Git push origin --delete ' . g:vira_active_issue)

endfunction

function! GitMerge() abort " {{{2
    " Merge active vira issue branch into dev

    if g:vira_active_issue !=# FugitiveHead()
      echom 'Issue and branch dont match'
      return
    endif

    " Hacky method to merge into dev if it exists, otherwise merge into master
    Git checkout master
    Git checkout dev

    " Merge message is like: 'VIRA-123: merge"
    execute('Git merge -m "'. g:vira_active_issue . ': merge" ' . ' --no-ff ' . g:vira_active_issue)
    Git push

endfunction

function! InstallVimspectorGadgets(info) " {{{2
  if a:info.status == 'installed' || a:info.force
    !./install_gadget.py --enable-python
    !./install_gadget.py --enable-go --update-gadget-config
    !./install_gadget.py --force-enable-csharp --update-gadget-config
    !./install_gadget.py --force-enable-node --update-gadget-config
  endif
endfunction

function! OnSave() " {{{2
  wshada
endfunction

function! MyTabLine() " {{{2
  let tabstring = ''

  for i in range(tabpagenr('$'))
    " select the highlighting
    if i + 1 == tabpagenr()
      let tabstring .= '%#TabLineSel#'
    else
      let tabstring .= '%#TabLine#'
    endif
    " set the tab page number (for mouse clicks)
    let tabstring .= '%' . (i + 1) . 'T'
    " the label is made by MyTabLabel()
    let tabstring .= ' %{MyTabLabel(' . (i + 1) . ')} '
  endfor

  " after the last tab fill with TabLineFill and reset tab page nr
  let tabstring .= '%#TabLineFill#%T'

  " " right-align the label to close the current tab page
  " if tabpagenr('$') > 1
    " let tabstring .= '%=%#TabLine#%999Xclose'
  " endif

  return tabstring
endfunction

function! MyTabLabel(n) " {{{2
  " The tab label looks better as file name only - without entire path
  let buflist = tabpagebuflist(a:n)
  let winnr = tabpagewinnr(a:n)
  let buf = bufname(buflist[winnr - 1])
  return fnamemodify(buf, ':t')
endfunction

function! PasteClipboard() abort " {{{2
  " See https://github.com/ferrine/md-img-paste.vim
  let targets = filter(
        \ systemlist('xclip -selection clipboard -t TARGETS -o'),
        \ 'v:val =~# ''image''')

  " Past regular text if not an image
  if empty(targets)
    normal! o
    normal! P==
    return
  endif

  let outdir = expand('%:p:h') . '/img'
  if !isdirectory(outdir)
    call mkdir(outdir)
  endif

  let mimetype = targets[0]
  let extension = split(mimetype, '/')[-1]
  let tmpfile = outdir . '/savefile_tmp.' . extension
  call system(printf('xclip -selection clipboard -t %s -o > %s',
        \ mimetype, tmpfile))

  let cnt = 0
  let filename = outdir . '/image' . cnt . '.' . extension
  while filereadable(filename)
    call system('diff ' . tmpfile . ' ' . filename)
    if !v:shell_error
      call delete(tmpfile)
      break
    endif

    let cnt += 1
    let filename = outdir . '/image' . cnt . '.' . extension
  endwhile

  if filereadable(tmpfile)
    call rename(tmpfile, filename)
  endif

  let @* = '![](./' . fnamemodify(filename, ':.') . ')'
  normal! o
  normal! "*P
endfunction

" Quit {{{2

" Close location list, preview window and quit
function! Quit()
    if (&buftype != "quickfix")
        lclose
    endif
    if (!&previewwindow)
        pclose
    endif
    quit
endf

function! SetCurrentWorkingDirectory() " {{{2
    " A standalone function to set the working directory to the project's root, or
    " to the parent directory of the current file if a root can't be found:
    let cph = expand('%:p:h', 1)
    if cph =~ '^.\+://' | retu | en
    for mkr in ['.git/', '.hg/', '.svn/', '.bzr/', '_darcs/', '.vimprojects']
        let wd = call('find'.(mkr =~ '/$' ? 'dir' : 'file'), [mkr, cph.';'])
        if wd != '' | let &acd = 0 | brea | en
    endfo
    exe 'lc!' fnameescape(wd == '' ? cph : substitute(wd, mkr.'$', '.', ''))
endfunction

function! StripComments(input) " {{{2
    " Strip comments and trim

    " Remove comments
    let substitution = substitute(a:input, b:NERDCommenterDelims['left'].'\|'.b:NERDCommenterDelims['right'], '', 'g')

    " Remove leading and trailing spaces
    let substitution = substitute(substitution, '^\s*\|\s*$', '', 'g')

    return substitution

endfunction

function! ToggleList(bufname, pfx) " {{{2
    " Toggle QuickFix/Location List, don't change focus
    let buflist = GetBufferList()
    for bufnum in map(filter(split(buflist, '\n'), 'v:val =~ "'.a:bufname.'"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
        if bufwinnr(bufnum) != -1
            " exec('quit')
            exec(a:pfx.'close')
            return
        endif
    endfor

    " Set orignal window
    let winnr = winnr()

    " Location List
    if a:pfx ==# 'l'
        " Nicer error message than original
        if len(getloclist(0)) == 0
            echohl ErrorMsg
            echo 'Location List is Empty.'
            return
        endif
        " Open window with minimum height
        exec 'bot '. w:locListHeight .a:pfx.'open'
        " QuickFix List
    elseif a:pfx ==# 'c'
        " Open window with minimum height
        exec 'top '. g:qfListHeight .a:pfx.'open'
    endif

    " Change focus back to the orignal window
    if winnr() != winnr
        wincmd p
    endif

endfunction

function! UserInput(prompt) " {{{2
    " Get a string input from the user
    " Get input from user
    call inputsave()
    let reply=input(a:prompt)
    call inputrestore()
    " Return the user's reply
    return l:reply
endfunction

function! WinDo(command) " {{{2
    " Just like windo, but restore the current window when done.
    let currwin=winnr()
    execute 'windo ' . a:command
    execute currwin . 'wincmd w'
endfunction

function! WrapFold(foldlevel) range " {{{2
    " Create a fold on the current line(s)
    let foldlevel = a:foldlevel
    if l:foldlevel == 0
        let foldlevel = foldlevel(line('.'))
        if l:foldlevel == 0
            let foldlevel = 1
        endif
    endif

    " User entered fold name
    let prompt = UserInput('Fold Text: ')

    " Abort the rest of the function if the user hit escape
    if (prompt == '') | return | endif

    " Prevent folding on seperate levels
    let foldLevelFirst = foldlevel(a:firstline)
    let foldLevelLast = foldlevel(a:lastline)
    if len(getline(a:firstline, a:lastline)) == 0 || l:foldLevelFirst != l:foldLevelLast
        return '' " No lines selected
    endif

    " Wrap selection with fold
    execute 'normal! mm'
    execute 'normal! ' . a:firstline . 'GO' . prompt . ' ' . g:fold_marker_string . l:foldlevel . "\<ESC>:call NERDComment(0,'toggle')\<CR>"
    execute 'normal! `m'
endfunction

" Commands {{{1
" Figlet {{{2
" Draw ascii art comments
command! -nargs=+ -complete=command Figlet
            \| silent call Figlet(<q-args>)

" Bufdo {{{2

" Just like bufdo, but restore the current buffer when done.
com! -nargs=+ -complete=command Bufdo call BufDo(<q-args>)

" Windo {{{2

" Just like windo, but restore the current window when done.
com! -nargs=+ -complete=command Windo call WinDo(<q-args>)

" Just like Windo, but disable all autocommands for super fast processing.
com! -nargs=+ -complete=command Windofast noautocmd call WinDo(<q-args>)

" CloseToggle {{{2
command! CloseToggle if (g:term_close == '') | let g:term_close = '++close' | echo 'Term will close' | else | let g:term_close = '' | echo 'Term will not close' | endif

" FindLocal {{{2
" Search for string in current file and put results in Location window
command! -nargs=+ -complete=command FindLocal
            \| silent call FindFunc(<q-args>, 'next') | set hls
" \| try | silent call FindFunc(<q-args>, 'next') | catch | endtry | set hls

" FoldOpen {{{2

" Suppress errors when no fold exists
" The catch part of the command prevents an error that would move the cursor when there are no folds in the file
command! FoldOpen let save_cursor = getcurpos() | try | silent foldopen! | catch | call setpos('.', save_cursor) | endtry

" Grep {{{2
" Use ag to grep and put results quickfix list
command! -nargs=+ Grep execute 'silent grep! --ignore node_modules --follow --hidden <args>' | let g:qfListHeight = min([ g:maxQFlistRecords, len(getqflist()) ]) | exe 'top ' . g:qfListHeight . ' copen' | redraw!
" Use flag in HA repo: --skip-vcs-ignores

" QuickFix/Location List Next {{{2
" Wrap around after hitting first/last record
command! Cnext try | cnext | catch | cfirst | catch | endtry
command! Cprev try | cprev | catch | clast | catch | endtry
command! Lnext try | lnext | catch | lfirst | catch | endtry
command! Lprev try | lprev | catch | llast | catch | endtry

" GoToMatchedColumn {{{2
" Since the QF list isn't populated with col numbers, this function allows you to jump to the proper column.
command! GoToMatchedColumn exe "normal b" | let @/=w:searchStr | call search(@/) | set hls

" Replace ^M Line endings {{{2

" Useful when converting from DOS to Unix line endings
command! ReplaceMwithBlank try | %s/\r$// | catch | endtry

" Useful when converting from DOS to Unix line endings
command! ReplaceMwithNewLine try | %s/\r/\r/ | catch | endtry

" Mani {{{2

command! -nargs=+ -complete=command Mani try |
            \ exe "sp term://mani -c ~/git/Linux/config/mani.yaml "
            \ . <q-args> . ""| catch | endtry

          " \ exe "terminal bash -c \"mani -c ~/git/Linux/config/mani.yaml "

" SpellToggle {{{2
command! SpellToggle if (&spell == 0) | setlocal spell | echo 'Spell-check enabled' | else | setlocal nospell | echo 'Spell-check disabled' | endif

" StartAsyncNeoVim {{{2

command! -nargs=1 StartAsyncNeoVim
         \ call jobstart(<f-args>, {
         \    'on_exit': { j,d,e ->
         \       execute('echom "command finished with exit status '.d.'"', '')
         \    }
         \ })

" ViraEnable {{{2
command! ViraEnable if (g:vira_commit_text_enable == '') | let g:vira_commit_text_enable = '+' | echo 'Jira issue git message prepending enabled' | else | let g:vira_commit_text_enable = '' | echo 'Jira issue git message prepending disabled' | endif

" Plugins{{{1
" Plugin Setup {{{2

augroup CustomSetFileType
  autocmd!
  autocmd BufRead,BufNewFile *.sebol setfiletype sebol
  autocmd BufRead,BufNewFile *.mmd setfiletype mermaid
augroup end

" _vim-plug {{{2

" Plugin manager

" Initialize plugin system
let vimPlugDir = vimHomeDir . '/plugged'
call plug#begin(vimPlugDir)

" Cheat.sh was not letting me perform Gdiff on .py files in Ubuntu18
" Plug 'dbeniamine/cheat.sh-vim'                              " cheat sheet

" Old plugins
" Plug 'file:///home/mike/.vim/plugged/test'
" Plug 'akinsho/toggleterm.nvim', {'tag' : '*'}                                 " NeoVim terminal improvements

Plug 'OmniSharp/omnisharp-vim'                                               " C# magic
Plug 'PProvost/vim-ps1'                                                      " Powershell file types
Plug 'Shougo/deoplete.nvim'                                                  " Auto-completion engine
Plug 'SirVer/ultisnips'                                                      " Snippet engine
Plug 'lukas-reineke/indent-blankline.nvim'                                   " Visual indent lines
Plug 'altercation/vim-colors-solarized'                                      " Color-scheme
Plug 'christoomey/vim-tmux-navigator'                                        " Switch beween vim splits & tmux panes seamslessly
Plug 'deoplete-plugins/deoplete-tag'                                         " Complete from ctags
Plug 'ervandew/supertab'                                                     " Insert mode completions
Plug 'godlygeek/tabular'                                                     " Align things
Plug 'honza/vim-snippets'                                                    " Snippet library
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }      " Preview md in brwoser
Plug 'jkramer/vim-checkbox'                                                  " Checkbox toggle
Plug 'junegunn/fzf.vim'                                                      " fzf plugin
Plug 'junegunn/gv.vim'                                                       " Access git files easier
Plug 'junegunn/vader.vim',  { 'on': 'Vader', 'for': 'vader'  }               " VimScript testing
Plug 'ludovicchabant/vim-gutentags'                                          " Manage ctags
Plug 'majutsushi/tagbar'                                                     " Use c-tags in real time and display tag bar
Plug 'mikeboiko/auto-pairs'                                                  " Auto-close brackets
Plug 'mikeboiko/vim-flow'                                                    " For a neat development workflow
Plug 'mikeboiko/vim-markdown-folding'                                        " Syntax based folding for md
Plug 'mikeboiko/vim-sort-folds'                                              " Sort vim folds
Plug 'mipmip/vim-scimark'                                                    " Spreadsheet magic
Plug 'mtdl9/vim-log-highlighting'                                            " log file highlighting
Plug 'n0v1c3/vira', { 'do': './install.sh', 'branch': 'dev'}                 " Jira integration
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}                  " Tree sitter
Plug 'nvim-treesitter/nvim-treesitter-textobjects'                           " Tree sitter text objects
Plug 'pbogut/fzf-mru.vim'                                                    " CtrlP style MRU files
Plug 'posva/vim-vue'                                                         " Vue filetype recognition
Plug 'puremourning/vimspector', {'do': function('InstallVimspectorGadgets')} " DAP
Plug 'rhysd/conflict-marker.vim'                                             " Git conflict resolution
Plug 'roosta/fzf-folds.vim', {'branch': 'main'}                              " fzf for folds
Plug 'roxma/nvim-yarp'                                                       " Auto-completion engine
Plug 'roxma/vim-hug-neovim-rpc'                                              " Auto-completion engine
Plug 'rust-lang/rust.vim'                                                    " Rusty stuff
Plug 'scrooloose/nerdcommenter'                                              " Commenting
Plug 'scrooloose/nerdtree'                                                   " Tree file browser
Plug 'tpope/vim-fugitive'                                                    " Git wrapper
Plug 'tpope/vim-repeat'                                                      " Repeat surround and commenting with .
Plug 'tpope/vim-rhubarb'                                                     " GitHub integration with fugitive
Plug 'tpope/vim-scriptease'                                                  " For debugging and writing plugins
Plug 'tpope/vim-surround'                                                    " Surround all the stuff
Plug 'vim-airline/vim-airline'                                               " Nice status bar
Plug 'vim-scripts/ReplaceWithRegister'                                       " Replace without copying to buffer
Plug 'w0rp/ale'                                                              " Async Linting
Plug 'yssl/QFEnter'                                                          " QuickFix lists - open in tabs/split windows

" End initialization of plugin system
call plug#end()

" ag - silver searcher {{{2
if executable('ag')
    " Use ag instead of grep (performance increase)
    " set grepprg=ag\ --nogroup\ --nocolor
    set grepprg=ag\ --silent\ --vimgrep\ $*
    set grepformat=%f:%l:%c:%m
endif

" airline {{{2

" Fix font inconsistencies
let g:airline_powerline_fonts=1

let g:airline_section_a = '%{g:vira_commit_text_enable}%{ViraStatusLine()}'

" ale {{{2

let g:ale_lint_on_text_changed = 'never'
let g:ale_hover_cursor = 0

let g:ale_linters = {
            \ 'cs': ['omnisharp'],
            \ 'go': ['gopls'],
            \ 'python': ['pyright'],
            \ 'vim': ['vimls', 'vint']
            \ }

let g:ale_fixers = {
            \ '*': ['remove_trailing_lines', 'trim_whitespace'],
            \ 'html': ['prettier'],
            \ 'go': ['gofmt'],
            \ 'javascript': ['prettier', 'eslint'],
            \ 'javascript.jsx': ['eslint'],
            \ 'json': ['prettier'],
            \ 'markdown': ['prettier'],
            \ 'python': ['yapf'],
            \ 'vue': ['prettier'],
            \ 'xml': ['prettier'],
            \ 'yaml': ['prettier']
            \ }

" This will prevent my searches from getting messed up
let g:ale_set_quickfix = 0
let g:ale_set_loclist = 0

" python language server config
" switched from pylsp to pyright, but I'll keep this here in case I switch back
let g:ale_python_pylsp_config = {
                          \   'pylsp': {
                          \     'plugins': {
                          \       'pyflakes': {
                          \         'enabled': v:false
                          \       },
                          \       'pycodestyle': {
                          \         'enabled': v:false
                          \       }
                          \     }
                          \   },
                          \ }

" C# fixer
let g:ale_c_uncrustify_options = '-c ~/git/Linux/config/uncrustify.cfg'

" Configure repo-specific linters/fixers
" let g:ale_pattern_options = {
            " \ 'Sync/SRS/*': {'ale_linters': ['pylint', 'pylsp']},
" \}
" let g:ale_pattern_options_enabled = 1
" let g:ale_python_pylint_options = '--rcfile ~/git/Work/SRS/.standard.rc'

" deoplete {{{2

let g:deoplete#enable_at_startup = 1
let deoplete#tag#cache_limit_size = 5000000
call deoplete#custom#option('smart_case', v:true)

call deoplete#custom#source('_',
		\ 'matchers', ['matcher_full_fuzzy'])

" Use the following plugins for completion of all filetypes
call deoplete#custom#option('sources', {
    \ '_': ['buffer', 'file', 'ale', 'tag'],
\})

" This fixes the problem of tabbing through the menu from top to bottom (reverse order)
let g:SuperTabDefaultCompletionType = '<c-n>'

" fugitive {{{2

augroup CustomFugitive
  autocmd!
  autocmd FileType gitcommit autocmd! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])
augroup end

" fzf {{{2

" Remap hotkeys

let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }

let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-s': 'split',
  \ 'ctrl-v': 'vsplit' }

" Disable preview window
let g:fzf_preview_window = []

" fzf-folds {{{2

let g:fzf_folds_open = 1

" indentLine {{{2

let g:indentLine_char = '│'

" markdownpreview {{{2

let g:mkdp_auto_close = 0
let g:mkdp_refresh_slow = 1

" nerdcommenter {{{2

" NerdCommenter add a space after comment
let g:NERDSpaceDelims=1

" Remove extra spaces when uncommenting
let g:NERDRemoveExtraSpaces=1

" Custom comment delimiters
let g:NERDCustomDelimiters = {
            \ 'python': { 'left': '#', 'right': '' },
            \ 'dosbatch': { 'left': 'REM', 'right': '' },
            \ 'kql': { 'left': '//', 'right': '' },
            \ 'mermaid': { 'left': '%%', 'right': '' },
            \ 'sebol': { 'left': '!', 'right': '' },
            \ 'vader': { 'left': '#'}
            \ }

" This used to happen automatically, but broke at ~v2.5
augroup CustomNERDcommenter
  autocmd!
  autocmd BufEnter * silent! call nerdcommenter#SetUp()
augroup end

" nerdtree{{{2

" Close NERDTree when opening file
let NERDTreeQuitOnOpen = 1

" Show hidden files by default
let NERDTreeShowHidden = 1

" Enable Bookmarks by default
let NERDTreeShowBookmarks = 1

" Line Numbers
let NERDTreeShowLineNumbers=1

" vim-tmux-navigator conflict
let g:NERDTreeMapJumpNextSibling = ''
let g:NERDTreeMapJumpPrevSibling = ''

" Open new files in splits/tabs
let g:NERDTreeMapOpenSplit = '<c-s>'
let g:NERDTreeMapOpenVSplit = '<c-v>'
let g:NERDTreeMapOpenInTab = '<c-t>'

" omnisharp {{{2

" C# linting/completion

" For WSL:
" First download the WINDOWS HTTP 64 bit release and place into directory below:
" https://github.com/OmniSharp/omnisharp-roslyn/releases

" For Arch Linux install dependencies:
" s pacman -S mono
" let g:OmniSharp_translate_cygwin_wsl = 1
" let g:OmniSharp_server_path = '/home/mike/.omnisharp/omnisharp-roslyn/omnisharp/OmniSharp.exe'
" let g:OmniSharp_port = 2000

" let g:OmniSharp_selector_ui = 'ctrlp'
let g:OmniSharp_timeout = 2
" let g:OmniSharp_highlight_types = 1
let g:OmniSharp_server_use_mono = 1
let g:OmniSharp_server_stdio = 1

" qfenter {{{2

let g:qfenter_keymap = {}
let g:qfenter_keymap.vopen = ['<C-v>']
let g:qfenter_keymap.hopen = ['<C-s>']
let g:qfenter_keymap.topen = ['<C-t>']

" toggleterm {{{2

if has('nvim')
  " lua require("toggleterm").setup{
        " \ open_mapping = [[<c-\>]],
        " \ hide_numbers = true
        " \ }
  autocmd! TermOpen term://* lua set_terminal_keymaps()
endif

" ultisnips {{{2

" YouCompleteMe and UltiSnips compatibility.
let g:UltiSnipsExpandTrigger = '<Tab>'
let g:UltiSnipsJumpForwardTrigger = '<Tab>'
let g:UltiSnipsJumpBackwardTrigger = '<S-Tab>'

" Additional UltiSnips config.
let g:UltiSnipsSnippetDirectories=[$HOME.'/git/Vim/snippets']

" vim-qf {{{2
" let g:qf_mapping_ack_style = 1

" vim-unstack {{{2

let g:unstack_populate_quickfix=1
let g:unstack_layout = "portrait"

" vimspector {{{2

let g:vimspector_enable_mappings = 'HUMAN'
let g:vimspector_enable_winbar=0

" See https://code.visualstudio.com/docs/python/debugging
" https://puremourning.github.io/vimspector/schema/vimspector.schema.json
let g:vimspector_configurations = {
      \ 'test_debugpy_config': {
      \   'adapter': 'debugpy',
      \   'filetypes': ['python'],
      \   'configuration': {
      \     'request': 'launch',
      \     'type': 'python',
      \     'cwd': '${fileDirname}',
      \     'args': ['*${ARGS}'],
      \     'program': '${file}',
      \     'python': '~/.pyenv/shims/python',
      \     'stopOnEntry': v:false,
      \     'console': 'integratedTerminal'
      \   },
      \   'breakpoints': {
      \     'exception': {
      \       'raised': 'Y',
      \       'uncaught': 'Y',
      \       'userUnhandled': 'Y'
      \     }
      \   }
      \ },
      \ 'delve_config': {
      \   'adapter': 'vscode-go',
      \   'filetypes': ['go'],
      \   'configuration': {
      \     'request': 'launch',
      \     'program': '${fileDirname}',
      \     'mode': 'debug',
      \     'dlvToolPath': '$HOME/go/bin/dlv'
      \   },
      \   'breakpoints': {
      \     'exception': {
      \       'raised': 'Y',
      \       'uncaught': 'Y',
      \       'userUnhandled': 'Y'
      \     }
      \   }
      \ },
      \ 'vscode-js-debug': {
      \   'adapter': 'js-debug',
      \   'filetypes': ['javascript'],
      \   'configuration': {
      \     'request': 'launch',
      \     'program': '${file}',
      \     'cwd': '${workspaceRoot}',
      \     'stopOnEntry': v:false
      \   },
      \   'breakpoints': {
      \     'exception': {
      \       'all': '',
      \       'uncaught': ''
      \     }
      \   }
      \ },
      \ 'netcoredbg': {
      \   'adapter': 'netcoredbg',
      \   'filetypes': ['cs'],
      \   'configuration': {
      \     'request': 'launch',
      \     'program': '${workspaceRoot}/bin/Debug/net7.0/dotnet-test.dll',
      \     'args': [],
      \     'stopAtEntry': v:false,
      \     'cwd': '${workspaceRoot}',
      \     'env': {}
      \   },
      \   'breakpoints': {
      \     'exception': {
      \       'raised': 'N',
      \       'uncaught': 'N',
      \       'userUnhandled': 'N'
      \     }
      \   }
      \ }
      \ }

let g:vimspector_sidebar_width = 70

" vimwiki {{{2

" let g:vimwiki_list = [{'path': '~/vimwiki/',
                      " \ 'syntax': 'markdown', 'ext': '.md'}]

" vira {{{2

let g:vira_config_file_projects = $HOME.'/git/Linux/config/vira_projects.yaml'
let g:vira_config_file_servers = $HOME.'/git/Linux/config/vira_servers.yaml'
let g:vira_issue_limit = 100

" let g:vira_report_width = 100

" Editor Settings {{{1
" Display{{{2

" 256 color
set t_Co=256

" Preferred background
set background=dark

" Preferred color scheme
silent! colorscheme solarized

" Solarized settings
" let g:solarized_italic=0
let g:solarized_bold=0
" This gets rid of the grey background
let g:solarized_termtrans = 1
set t_Cs="Fix bad spell issue in solarized theme"

" Set GVIM Font
" To select form availbale fonts :set guifont=*
if has("unix")
    set guifont=Ubuntu\ Mono\ 13
else
    set guifont=Consolas:h12
endif

" Display line number for current line
set number

" Display relative line number along the left hand side
" set relativenumber

" Start scrolling <x> lines before window border
set scrolloff=8

" Visual auto complete for command menu
set wildmenu

" Show command in bottom bar
set showcmd

" Don't show Insert/Normal Mode status on last line
set noshowmode

" Do not redraw during operations such as macro
set lazyredraw

" Don't wrap/line break in the middle of a word
set linebreak

" Always display the status line even if only one window is displayed
set laststatus=2

" Display hidden char
let g:display_hidden = "hidden"

" Change the text that is displayed while in a fold
set foldtext=v:folddashes.FormatFoldString(v:foldstart)

" Get rid of that ugly x in top right corner or tabline
set tabline=%!MyTabLine()

" Functionality {{{2
" Vim Start {{{3

" Save last file when exiting vim
" autocmd VimLeave * nested if (!isdirectory(vimHomeDir)) |
            " \ call mkdir(vimHomeDir) |
            " \ endif |
            " \ execute "mksession! " . vimHomeDir . "/Session.vim"

" " Go to last file(s) if invoked without arguments.
" autocmd VimEnter * nested if argc() == 0 &&
            " \ filereadable(vimHomeDir . "/Session.vim") |
            " \ try |
            " \ execute "source " . vimHomeDir . "/Session.vim"
            " \ | catch | endtry

" Have Vim jump to the last position when reopening a file
augroup CustomLastPosition
  autocmd!
  autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
              \| exe "normal! g'\"" | endif
augroup end

augroup VimOnExit
  autocmd!
  autocmd VimLeave * call fzf_mru#mrufiles#refresh()
augroup end

" General{{{3

" Optimize GVim
if has('GUI')
    " Disable annoying error bell sounds
    autocmd GUIEnter * set vb t_vb=

    " Open GVim in Maximized mode
    if has("unix")
        autocmd GUIEnter * call system('wmctrl -i -b add,maximized_vert,maximized_horz -r '.v:windowid)
    else
        autocmd GUIEnter * simalt ~x
    endif

    " Remove Menubar and Toolbar from GVIM
    set guioptions -=m
    set guioptions -=T
endif

" Increase number of oldfiles. Original is 100. Used in fzf-vim :History
" Don't save selected buffer naes to shadafile
if has('nvim')
  set shada=!,'500,<50,s10,h
  " set shada^=rterm://,rfugitive
endif

" General settings required for highlighting
" I removed this line because it was giving me an error in vira for =bg
" syntax on

" Enable plug-ins for indentation
filetype plugin indent on

" Eliminate command windows escape delay
set timeoutlen=500 ttimeoutlen=0

" Backspace over auto indent, line breaks, start of insert
set backspace=indent,eol,start

" Remove vi compatibility
set nocompatible

" Update when idle for x ms (default is 4000 msec)
set updatetime=500

" Virtual editing, position cursor where there is are no characters (all modes)
set virtualedit=all

" Ignore file patterns globally
set wildignore+=*.swp
set wildignore+=package.json,package-lock.json,node_modules

" Standard Encoding
set encoding=utf8

" No .swp backup files
set noswapfile

" Use linux shard clipboard in VIM
if has('mac') || has('win32')
    set clipboard=unnamed,unnamedplus
elseif has('unix')
    set clipboard=unnamedplus
endif

" https://github.com/neovim/neovim/blob/master/runtime/autoload/provider/clipboard.vim#L88
let g:clipboard = {
      \   'name': 'xsel clipboard',
      \   'copy': {
      \      '+': ['clipsy', 'copy'],
      \      '*': ['clipsy', 'copy'],
      \    },
      \   'paste': {
      \      '+': ['clipsy', 'paste'],
      \      '*': ['clipsy', 'paste'],
      \   },
      \   'cache_enabled': 1,
      \ }

" Vertical splits open on the right instead of the default of left
set splitright

" Automatically change current directory when new file is opened
set autochdir

" This diables tmux mouse features while inside vim
set mouse=a

" Enable Vim to check for modelines throughout your files
" best practice to keep them at the top or the bottom of the file
set modeline
" Number of modelines to be checked, if set to zero then modeline checking
" will be disabled
set modelines=5

set autoread

augroup CustomOptions
  autocmd!
  " Don't add comment automatically on new line
  autocmd FileType * setlocal formatoptions-=cro
  " Auto reload file when changed from another source
  autocmd CursorHold * if &buftype != "nofile" | checktime | endif
  " Peform actions right before saving bugger
  " autocmd BufWritePre * call OnSave()
  " Preview Window
  autocmd WinEnter * if &previewwindow | setlocal foldmethod=manual | endif
  " Enable spelling for these buffers
  autocmd BufWinEnter,BufEnter COMMIT_EDITMSG setlocal spell
augroup end

" Spelling
set spellfile=$HOME/files/Sync/Documents/en.utf-8.add

" Change error format for custom FindFunc() usage
" set efm+=%f:%l:%m

" nvim terminal
if has('nvim')
  augroup nvim_term
    autocmd!
    autocmd TermOpen *gap, startinsert
    autocmd TermClose *gap stopinsert
    autocmd TermOpen */dotnet-build.sh* call timer_start(10000, { -> vimspector#Launch() })
  augroup END
endif

" Required for fzf-folds
if has('mac')
  set runtimepath+=/usr/local/opt/fzf
endif

" Without this ctrl+a skips 8s and 9s when incrementing
set nrformats-=octal

" Cursor changes from block to line in insert mode
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"

" Indenting/Tabs{{{3
" Do smart auto indenting when starting a new line
set autoindent
" set smartindent

" Set tab width
set tabstop=4
set softtabstop=4
set shiftwidth=0

" Use spaces instead of tabs
set expandtab
" Delete spaces like tabs
set smarttab

" Searching{{{3
" Search as characters are entered
set incsearch
" Highlight search
set hlsearch
" Ignore case of given search term
set ignorecase
" Only search for matching capitals when they are used
set smartcase

" QuickFix/Location {{{3

" Align QuickFix on ver unique string '$}{$'
augroup CustomQuickFix
  autocmd!
  autocmd BufReadPost quickfix setlocal modifiable
              \| silent exe 'Tab /|\$}{\$'
              \| silent exe 'g/\$}{\$/s/'
              \| setlocal nowrap
              \| setlocal norelativenumber
              \| setlocal cursorline
              \| setlocal nomodifiable
  " Close QuickFix/Location lists automatically when it's the last window in current tab
  autocmd BufEnter * call CloseQuickFixWindow()
augroup end

" \| nnoremap <buffer> <CR> <CR>:FoldOpen<CR>
" \| nnoremap <buffer> <CR> <CR>:FoldOpen<CR>:GoToMatchedColumn<CR>

" Undo Files {{{3
" Let's save undo info!
if !isdirectory(vimHomeDir)
    call mkdir(vimHomeDir, "", 0770)
endif
if !isdirectory(vimHomeDir . "/undo-dir")
    call mkdir(vimHomeDir."/undo-dir", "", 0700)
endif
set undodir=~/.vim/undo-dir
set undofile

" Language/Project Specific{{{1
" Comma/Pipe/Tab Seperated Values{{{2
" autocmd BufReadPost *.tsv,*.csv,*.psv execute 'Tabularize /,'
augroup CustomFileTypes
  autocmd!
  autocmd BufReadPost *.csv setlocal nowrap
  autocmd BufReadPost *.psv setlocal nowrap
  autocmd BufReadPost *.tsv setlocal nowrap
  " autocmd BufReadPost *.csv 1sp
  " autocmd BufReadPost *.psv 1sp
  " autocmd BufReadPost *.tsv 1sp
  " HTML/js/css/etc
  autocmd FileType html,javascript,json,vue,css,scss,yml,yaml,markdown,vim setlocal tabstop=2
  " Markdown -Fix the syntax highlighting that randomly stops
  autocmd FileType markdown set foldexpr=NestedMarkdownFolds()
augroup end

" Speed up vim when in vue files
let g:vue_disable_pre_processors=1

" NERDCommenter fix
" En error occured when putting this code into a seperate vim.vue file

let g:ft = ''

function! NERDCommenter_before()
    if &ft == 'vue'
        let g:ft = 'vue'
        let stack = synstack(line('.'), col('.'))
        if len(stack) > 0
            let syn = synIDattr((stack)[0], 'name')
            if len(syn) > 0
                exe 'setf ' . substitute(tolower(syn), '^vue_', '', '')
            endif
        endif
    endif
endfunction

function! NERDCommenter_after()
    if g:ft == 'vue'
        setf vue
        let g:ft = ''
    endif
endfunction

" Mappings{{{1
" Leader key {{{2
let mapleader="\<space>"

" Add char to EOL {{{2

" Colon
inoremap :: <esc>mzA:<esc>`z
nnoremap <leader>a: mzA:<esc>`z

" Comma
inoremap ,, <esc>mzA,<esc>`z
nnoremap <leader>a, mzA,<esc>`z

" Period
nnoremap <leader>a. mzA.<esc>`z

" Semi-Colon
inoremap ;; <esc>mzA;<esc>`z
nnoremap <leader>a; mzA;<esc>`z

" ALE {{{2

nnoremap <leader>se :call ALERunLint()<CR>
nnoremap <leader>aw :ALEFindReferences -quickfix<CR>:top 5 copen<CR>

" Clipboard {{{2

nnoremap <leader>cfp :let @+ = expand("%:p:~")<CR>
nnoremap <leader>cwd :let @+ = expand("%:p:~:h")<CR>

" Close Toggle {{{2
" Toggle between ++close and ++noclose when running term <leader>rr
nnoremap <leader>ct :CloseToggle<CR>

" Close all location lists {{{2

nnoremap <leader>ac :call AllClose()<CR>

" Commands {{{2

" Rerun last command
nnoremap qr @:

" Get into command history
nnoremap q; q:

" Comment {{{2

" Main Comment Mappings
nnoremap cii :call PromptAndComment(1, 'Comment Text: ', '')<CR>
map cl <plug>NERDCommenterToggle
map cp vip<plug>NERDCommenterYank
map cu vip<plug>NERDCommenterUncomment

" Inline comments with folds
map ci1 <plug>NERDCommenterAppend<c-r>=g:fold_marker_string<CR>1<ESC>
map ci2 <plug>NERDCommenterAppend<c-r>=g:fold_marker_string<CR>2<ESC>
map ci3 <plug>NERDCommenterAppend<c-r>=g:fold_marker_string<CR>3<ESC>
map ci4 <plug>NERDCommenterAppend<c-r>=g:fold_marker_string<CR>4<ESC>

" Comment, Yank and Paste
nnoremap cy "zyy:silent execute "cal NERDComment('n',\"comment\")"<CR>"zp
vnoremap cy "zY:<c-u>silent execute "cal NERDComment('v',\"comment\")"<CR>}"zP

" Conflicts {{{2

" This is to fix a <C-r> conflict
nmap <leader>redo <Plug>(RepeatRedo)

" Convert Line Endings {{{2

" Convert to Dos
nnoremap <leader>ctd mz:e ++ff=dos<CR>`z

" Convert to Mac
nnoremap <leader>ctm mz:e ++ff=mac<CR>`z

" Convert to Unix
nnoremap <leader>ctu mz:e ++ff=unix<CR>:ReplaceMwithBlank<CR>`z

" FZF {{{2

" nnoremap <c-p> :rshada!<cr>:call AllClose()<cr>:History<cr>
nnoremap <c-p> :FZFMru<cr>
nnoremap <leader>p :GFiles<cr>
nnoremap <leader>. :Tags<cr>

" https://github.com/junegunn/fzf.vim#commands
" :Files [PATH]	Files
" :GFiles [OPTS]	Git files (git ls-files)
" :Maps	Normal mode mappings

" Cycle through Auto-Suggestions {{{2
inoremap <c-j> <c-n>
inoremap <c-k> <c-p>

" Dump Register {{{2
nnoremap <leader><space> "z

" End/Beginning of Line {{{2
nnoremap <silent> H ^
nnoremap <silent> L $
vnoremap <silent> H ^
vnoremap <silent> L $
omap H ^
omap L $

" Escape Key {{{2

" Disable Highlighting
" When I used a single escape, vim started in Replace mode everytime
nnoremap <esc><esc> :noh<esc>

" Find Local {{{2

" Find string in current file
nnoremap <leader>fl :FindLocal<space>

" Find word under cursor
map <leader>fw "xyiw:call FindFunc("\\<".@x."\\>", '')<CR>

" Fix errors {{{2
nnoremap <leader>fi :ALEFix<CR>

" Folding {{{2

" Fold Everything except for the current section
nnoremap zx zMzvzz

" Create Folds
noremap <silent> <leader>zz :call WrapFold(v:count)<CR>
noremap <silent> <leader>zj :call WrapFold(foldlevel(line(".")) + 1)<CR>
noremap <silent> <leader>zk :call WrapFold(foldlevel(line(".")) - 1)<CR>

" Font Size Bigger/Smaller {{{2

" Font Hotkeys
if has("gui_running")
    nmap <S-F6> :call FontSizeMinus()<CR>
    nmap <F6> :call FontSizePlus()<CR>
endif

" Git {{{2

" Fugitive remappings
nnoremap <leader>gd :Gvdiffsplit!<Space>
nnoremap <leader>gdt :Git difftool -y<CR>
nnoremap <leader>gs :Git<CR>

" Display git diff in terminal
nnoremap <leader>rd :terminal git --no-pager diff<CR>

" Mani commands
nnoremap <leader>ms :Mani run git-status --parallel --tags $MANI_TAG<cr>
nnoremap <leader>mu :Mani run git-up --parallel --tags $MANI_TAG<cr>

" Add all changes, commit and push
nnoremap <leader>gap :wa<CR>:silent call GitAddCommitPush()<CR>

" Create new git branch based on active vira issue
nnoremap <leader>gnb :call GitNewBranch()<cr>

" Delete branch for active vira issue
nnoremap <leader>gdb :call GitDeleteBranch()<cr>

" Merge active vira issue branch into the dev branch
nnoremap <leader>gm :call GitMerge()<cr>

" Go to Definition{{{2

" Go to definition and focus on fold
nnoremap gd zR:ALEGoToDefinition<CR>

" Preview definition and focus on fold
map gt mm:tabe %<CR>`mgdzMzvzz
map gs mm:sp %<CR>`mgdzMzvzz
map gv mm:vs %<CR>`mgdzMzvzz

" Grep with ag {{{2

" Search code
nnoremap <leader>fc :Grep --<c-r>=&filetype<CR> ~/git<s-left><space><left>

" Search notes
nnoremap <leader>fn :Grep --md ~/git<s-left><space><left>

" Search git repo
nnoremap <leader>fg :let @q = system('git rev-parse --show-toplevel')[:-2]<CR>:Grep "<c-r>q"<home><s-right><space>

" Search for word under cursor in git repo
map <leader>gw "xyiw:let @q = system('git rev-parse --show-toplevel')[:-2]<CR>:Grep <c-r>x "<c-r>q"<cr>

" Help {{{2

" Pull up help for word under cursor in a new tab
nnoremap <expr> <leader>h ":help " . expand("<cword>") . "\n"

" Marks {{{2
" Jump to proper column when using marks
nnoremap ' `

" NERDTree {{{2
nnoremap <leader>on :NERDTreeFind<CR>

" Mouse {{{2

" Enable mouse scrolling but not clicking
nmap <LeftMouse> <nop>
imap <LeftMouse> <nop>
vmap <LeftMouse> <nop>

" Navigation {{{2
" Do not automatically adjust for line wrapping
nnoremap <expr> j v:count ? 'j' : 'gj'
nnoremap <expr> k v:count ? 'k' : 'gk'

" Go back to the last file
nnoremap <BS> <C-^>

" NeoVim {{{2

if has('nvim')
  lua require("mappings")
  lua require("treesitter")
endif

" New line {{{2

" Add blank line after current line
nnoremap <leader>aj :<CR>mzo<Esc>`z:<CR>

" Add blank line before current line
nnoremap <leader>ak :<CR>mzO<Esc>`z:<CR>

" Add blank line before and after current line
nnoremap <leader>al :<CR>mzO<Esc>jo<Esc>`z:<CR>

" Restore Enter key functionality for command history window
" autocmd CmdwinEnter * nnoremap <buffer> <CR> <CR>

" Open File/Folder {{{2

" Explorer
nnoremap <leader>oe :silent !explorer.exe .<CR>:redraw!<CR>

" Browser
nnoremap <leader>ob :MarkdownPreview<CR>

" Double Commander
nnoremap <leader>od :Start -wait=never "C:\Program Files\Double Commander\doublecmd.exe" %:p:h<CR>:redraw!<CR>

" QuickFix/Location Lists {{{2

" I put this at the end of the mapping section because of some conflicts with <c-r>

" Go to next/previous search result
" nnoremap <leader>zf zMzvzz
nnoremap <C-f> :Lnext<CR>:GoToMatchedColumn<CR>:FoldOpen<CR>
nnoremap <C-d> :Lprev<CR>:GoToMatchedColumn<CR>:FoldOpen<CR>
nnoremap <C-R> :Cnext<CR>:FoldOpen<CR>
nnoremap <C-E> :Cprev<CR>:FoldOpen<CR>

nmap <silent> <leader>l :call ToggleList("Location List", 'l')<CR>
nmap <silent> <leader>q :call ToggleList("Quickfix List", 'c')<CR>

" Plugins {{{2

" Quit {{{2

" Close extra windows then quit
inoremap <c-q> <esc>:up<CR>:call Quit()<CR>
nnoremap <c-q> :up<CR>:call Quit()<CR>
nnoremap <c-w> :call Quit()<CR>
nnoremap qq :call Quit()<CR>

" Close all windows in tab
nnoremap qt :tabclose<CR>

" Close without saving
nnoremap Q :q!<CR>

" A hack to close the Fugitive Plugin window with <c-w>
nmap gf gf

" Exit command history window q: or q/ with <c-w>
augroup CustomCommandHistory
  autocmd!
  autocmd CmdwinEnter * nnoremap <buffer> <c-w> :q!<CR> |
              \ nnoremap <buffer> qq :q!<CR>
augroup end

" Rename Tag {{{2

" Copy word under cursor into "a and paste into new buffer
nnoremap <leader>rt mz"ayiw:1sp wordRenamingBuffer<CR>"aP

" After edits, press enter, the original word is renamed globally
" The search is case sensitive because of I in .../gI
" Press escape to cancel
augroup RenamingBuffer
  autocmd!
  autocmd BufWinEnter,BufEnter wordRenamingBuffer setlocal modifiable
        \| nnoremap <buffer> <Esc> :q!<CR>
        \| nnoremap <buffer> <c-s> <nop>
        \| nnoremap <buffer> qw <nop>
        \| nnoremap <buffer> <Enter>
        \ b"byiw:q!<CR>:%s/\<<c-r>a\>/<c-r>b/gI<CR>`z
augroup END

" Reports {{{2

if has('nvim')
  nnoremap <leader>tp :tabe term:///usr/bin/python ~/git/Tables/scripts/tables.py cli -f printbalance<CR>
  nnoremap <leader>cw :tabe term://curl wttr.in/Calgary?m"<CR>
else
  nnoremap <leader>tp :tabe<CR>:terminal ++curwin bash -c "python ~/git/Tables/scripts/tables.py cli -f printbalance"<CR><CR>
  nnoremap <leader>cw :tabe<CR>:terminal ++curwin bash -c "curl wttr.in/Calgary"<CR>
endif

" Run Scripts {{{2

" Run Script in terminal
nnoremap <silent> <leader>rr :wa<CR>:FlowRun<CR>

" Save Buffer {{{2

nnoremap qw :w<CR>
nnoremap <c-s> :w<CR>
inoremap <c-s> <esc>:w<CR>

" Scrolling{{{2

" Scroll Up
nnoremap K 5k
vnoremap K 5k

" Scroll Down
nnoremap J 5j
vnoremap J 5j

" Show and Trim Spaces {{{2

nnoremap <leader>ts :ALEFix trim_whitespace<CR>

" Search {{{2
" Search for multiple terms
nnoremap <leader>/ /\v<c-r>/\|

" Decided to disable this so it's not confusing when I use other applications with vi mode such as tmux
" Search forward and backwards consistently
" nnoremap <expr> n 'Nn'[v:searchforward]
" nnoremap <expr> N 'nN'[v:searchforward]

" Sorting {{{2
" Sort paragraph
nnoremap <leader>so vip:sort<CR>

" Source {{{2
nnoremap <leader>sv :w<CR>:so $HOME/.vimrc<CR>

" Spell Toggle {{{2
" Toggle the spelling on/off
nnoremap <leader>st :SpellToggle<CR>

" Suspend {{{2

" Don't suspend!
noremap <c-z> <nop>
" noremap <c-z>c :Start! ~/clipboard.sh --write<CR>
" noremap <c-z>v :Start! ~/clipboard.sh --read<CR>

" TODOs {{{2

" Add new TODO above current line
let todoPrefix = 'TODO-MB [' . strftime('%y%m%d') . '] - '
nnoremap <silent> <leader>ti :call PromptAndComment(0, 'TODO: ', todoPrefix)<CR>

" Tabs {{{2

" Open current file in new tab
nnoremap <c-t> mm:tabe <c-r>%<CR>`m

" Toggle tabs
nnoremap qm gt
nnoremap qn gT
nnoremap <C-g> :tabp<CR>

" TagBar {{{2
nnoremap <leader>tb ::TagbarOpenAutoClose<CR>

" Vimspector {{{2

nmap <silent> <leader>db :call vimspector#BreakpointsAsQuickFix()<cr>
nmap <silent> <leader>di <Plug>VimspectorBalloonEval
nmap <silent> <leader>dc :wa<CR>:execute "normal \<Plug>VimspectorContinue"<CR>
nmap <silent> <leader>dr :wa<CR>:execute "normal \<Plug>VimspectorRestart"<CR>
nmap <silent> <leader>dp <Plug>VimspectorPause
nmap <silent> <leader>ds <Plug>VimspectorStop
nmap <silent> <leader>dsi <Plug>VimspectorStepInto
nmap <silent> <leader>dso <Plug>VimspectorStepOut

" Default mappings:

" <leader+CR> |                                  | Edit variable value
" F3          | <Plug>VimspectorStop             | Stop debugging.
" F4          | <Plug>VimspectorRestart          | Restart debugging.
" F5          | <Plug>VimspectorContinue         | When debugging, continue. Otherwise start debugging.
" F6          | <Plug>VimspectorPause            | Pause debuggee.
" <leader>F8  | <Plug>VimspecdtorRunToCursor     | Run to Cursor
" F9          | <Plug>VimspectorToggleBreakpoint | Toggle line breakpoint on the current line.
" F10         | <Plug>VimspectorStepOver         | Step Over
" F11         | <Plug>VimspectorStepInto         | Step Into
" Shift F11   | <Plug>VimspectorStepOut          | Step out of current function scope

" In order to see Traceback, add __traceback__ to Watch Window

" Vira {{{2

" Basics
nnoremap <silent> <leader>vI :ViraIssue<cr>
nnoremap <silent> <leader>vc :ViraComment<cr>
nnoremap <silent> <leader>vi :ViraIssues<cr>
nnoremap <silent> <leader>vr :ViraReport<cr>

" Set
nnoremap <silent> <leader>vsS :silent! ViraServers<cr>
nnoremap <silent> <leader>vsa :silent! ViraSetAssignee<cr>
nnoremap <silent> <leader>vsc :silent! ViraSetComponent<cr>
nnoremap <silent> <leader>vse :silent! ViraSetEpic<cr>
nnoremap <silent> <leader>vsp :silent! ViraSetPriority<cr>
nnoremap <silent> <leader>vss :silent! ViraSetStatus<cr>
nnoremap <silent> <leader>vst :silent! ViraSetType<cr>
nnoremap <silent> <leader>vsv :silent! ViraSetVersion<cr>

" Filters
nnoremap <silent> <leader>vfE :ViraFilterEpics<cr>
nnoremap <silent> <leader>vfP :ViraFilterProjects<cr>
nnoremap <silent> <leader>vfR :ViraFilterReporter<cr>
nnoremap <silent> <leader>vfT :ViraFilterTypes<cr>
nnoremap <silent> <leader>vfa :ViraFilterAssignees<cr>
nnoremap <silent> <leader>vfc :ViraFilterComponents<cr>
nnoremap <silent> <leader>vfe :ViraFilterEdit<cr>
nnoremap <silent> <leader>vfp :ViraFilterPriorities<cr>
nnoremap <silent> <leader>vfr :ViraFilterReset<cr>
nnoremap <silent> <leader>vfs :ViraFilterStatuses<cr>
nnoremap <silent> <leader>vft :ViraFilterReset<cr>:python3 Vira.api.userconfig_filter["statusCategory"] = ""<cr>:ViraFilterText<cr>
nnoremap <silent> <leader>vfv :ViraFilterVersions<cr>

" Boards
nnoremap <silent> <leader>vbf :ViraLoadProject Model<cr>:ViraIssues<cr>
nnoremap <silent> <leader>vbh :ViraLoadProject Home<cr>:ViraIssues<cr>
nnoremap <silent> <leader>vbi :ViraLoadProject Inbox<cr>:ViraIssues<cr>
nnoremap <silent> <leader>vbj :ViraLoadProject Jesse<cr>:ViraIssues<cr>
nnoremap <silent> <leader>vbm :ViraLoadProject __default__<cr>:ViraIssues<cr>
nnoremap <silent> <leader>vbn :ViraLoadProject Nuance<cr>:ViraIssues<cr>
nnoremap <silent> <leader>vbv :ViraLoadProject vira<cr>:ViraIssues<cr>
nnoremap <silent> <leader>vbw :ViraLoadProject Work<cr>:ViraIssues<cr>

" Misc
nnoremap <silent> <leader>vsi :let g:vira_active_issue="
nnoremap <silent> <leader>vb :ViraBrowse<cr>
nnoremap <silent> <leader>ve :ViraEnable<cr>

" Windows Style Commands {{{2

" Redo
nnoremap <c-y> <c-r>
inoremap <c-y> <Esc><C-r>

" Paste from clipboard
nnoremap <c-v> :call PasteClipboard()<cr>
inoremap <c-v> <c-r>+
cmap <c-v> <c-r>+

" Windows {{{2

" Move between windows/panes
nnoremap qj <C-W>j
nnoremap qk <C-W>k
nnoremap qh <C-W>h
nnoremap ql <C-W>l
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l

tnoremap <C-g> <C-W>:tabp<CR>
tnoremap <C-j> <C-W>j
tnoremap <C-k> <C-W>k
tnoremap <C-h> <C-W>h
tnoremap <C-l> <C-W>l

" Yank {{{2
" Yank till the end of the line
nnoremap Y y$

" Yank all
nnoremap <leader>ya mzggyG`z

" Templates {{{1
" Load template based on current file extension (:help template)

augroup templates
    " Remove ALL auto commands for the current group
    autocmd!
    " Expand file extension and search templates placing content at top of file
    autocmd BufNewFile main.* silent! execute '0r $CODE/Vim/templates/skeleton.'.expand("<afile>:e")
    " Substitute equations between the VIM_EVAL and END_EVAL equations
    " autocmd BufNewFile * %substitute#\[:VIM_EVAL:\]\(.\{-\}\)\[:END_EVAL:\]#\=eval(submatch(1))#ge
augroup END
