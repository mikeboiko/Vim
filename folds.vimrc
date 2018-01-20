" This code was messing up my main vimrc file folding structure
" So it's easier to keep it in a separate file

" Change the text that is displayed while in a fold
set foldtext=v:folddashes.FormatFoldString(v:foldstart)

" Make the status string a list of all the folds
function! GetFoldStrings()
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

" Get the text of the last fold
function! GetLastFoldString()
    return FormatFoldString(GetLastFoldLineNum(foldlevel(".")))."|"
endfunction

" Format fold string so it looks neat
function! FormatFoldString(lineNum)
    " Get the line string of the current fold and remove special chars
    let line = getline(a:lineNum)
    " Remove programming language specific words
    let line = RemoveFiletypeSpecific(line)
    " Remove special (comment related) characters and extra spaces
    let line = RemoveSpecialCharacters(line)
    return line
endfunction

" Get the line number of last Fold
function! GetLastFoldLineNum(foldLvl)
    " Only search current line for fold marker
    let line = search("{{{".a:foldLvl,"n",line("."))
    " Search backwards for fold marker
    if (line==0)
        let line = search("{{{".a:foldLvl,"bn")
    endif
    return line
endfunction

" Remove special (comment related) characters and extra spaces
" Characters: " # ; /* */ // {{{\d <!-- -->
function! RemoveSpecialCharacters(line)
    " Remove special characters
    let text = substitute(a:line, '<!--\|-->\|\"\|#\|;\|/\*\|\*/\|//\|{{{\d\=', '', 'g')
    " Replace 2 or more spaces with a single space
    let text = substitute(text, ' \{2,}', ' ', 'g')
    " Remove leading and trailing spaces
    let text = substitute(text, '^\s*\|\s*$', '', 'g')
    " Remove text between () in functions
    let text = substitute(text, '(\(.*\)', '()', 'g')
    " Add nice padding
    return " ".text." "
endfunction

" Remove programming language specific words
function! RemoveFiletypeSpecific(line)
    let text = a:line
    if (&ft=='python')
        " Functions/Classes
        let text = substitute(a:line, '\<def\>\|\<class\>', '', 'g')
    elseif  (&ft=='cs')
        " Functions/Events
        let text = substitute(a:line, '\<static\>\|\<int\>\|\<float\>\|\<void\>\|\<string\>\|\<bool\>\|\<private\>\|\<public\>\s', '', 'g')
    elseif  (&ft=='vim')
        " Functions/Events
        let text = substitute(a:line, '\<function\>!\s', '', 'g')
    endif
    return text
endfunction

"Comment with fold levels - inline
" TODO-MB [171114] - Use Tabular alignment with comment character
" map <leader>ci1 <plug>NERDCommenterAppend{{{1<CR>
let fold_marker_string = "{{{"
map <leader>ci1 <plug>NERDCommenterAppend<c-r>=fold_marker_string<CR>1<ESC>
map <leader>ci2 <plug>NERDCommenterAppend<c-r>=fold_marker_string<CR>2<ESC>
map <leader>ci3 <plug>NERDCommenterAppend<c-r>=fold_marker_string<CR>3<ESC>
map <leader>ci4 <plug>NERDCommenterAppend<c-r>=fold_marker_string<CR>4<ESC>

" Travis's Fold Function

" Create a fold on the current line(s)
function! WrapFold(foldlevel) range
    let foldlevel = a:foldlevel
    if l:foldlevel == 0
        let foldlevel = foldlevel(line('.'))
        if l:foldlevel == 0
            let foldlevel = 1
        endif
    endif

    " User entered fold name
    let prompt = UserInput(g:prompt_wrapFold)

    " TODO [171105] - Do I need this anymore?

    " Prevent folding on seperate levels
    let foldLevelFirst = foldlevel(a:firstline)
    let foldLevelLast = foldlevel(a:lastline)
    if len(getline(a:firstline, a:lastline)) == 0 || l:foldLevelFirst != l:foldLevelLast
        return '' " No lines selected
    endif

    " Wrap selection with fold
    execute 'normal! mm'
    execute 'normal! ' . a:firstline . 'GO' . prompt . ' {{{' . l:foldlevel . "\<ESC>:call NERDComment(0,'toggle')\<CR>"
    execute 'normal! `m'
endfunction

" vim: foldmethod=manual:foldlevel=5
