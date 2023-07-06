" =======================================================================
" === Description ...: Markdown Settings
" === Author ........: Mike Boiko
" =======================================================================

" " Auto Format Document for Folding
" function! FormatMDFunc()
    " g/^#\s\(.*-->\)\@!/s/$/ <!-- {{{1 -->
    " g/^##\s\(.*-->\)\@!/s/$/ <!-- {{{2 -->
    " g/^###\s\(.*-->\)\@!/s/$/ <!-- {{{3 -->
" endfunction
" nnoremap <buffer> <c-s> :silent call FormatMDFunc()<CR>:noh<CR>:w<CR>

" Fix red highlighting when there's an _ in a word
syn match markdownError "\w\@<=\w\@="

" Turn on spell-check
setlocal spell

function! s:SurroundWithBackticks()
  " execute "normal! {o```\<ESC>}O```\<ESC>"
  let l:old_reg = @@

  " Save the current cursor position
  let l:start_pos = getpos('.')
  let l:cur_pos = getpos('.')

  " Move to the beginning of the paragraph
  normal! {
  let l:start_line = line('.')

  " Move to the end of the paragraph
  normal! }
  let l:end_line = line('.')

  " Count the number of empty lines at the end of the paragraph
  while l:end_line < line('$') && getline(l:end_line) =~# '^\s*$'
    let l:end_line += 1
  endwhile

  " Move back to the beginning of the paragraph
  call setpos('.', l:cur_pos)

  " Surround the paragraph with backticks
  execute l:start_line . 's/^/\r```' | let l:start_line += 1
  execute l:end_line . 's/$/```\r' | let l:end_line

  " Adjust the cursor position after the modification
  let l:cur_pos[1] += l:start_line - 1
  let l:cur_pos[2] = 1
  call setpos('.', l:start_pos)

  " Restore the default register contents
  let @@ = l:old_reg
endfunction

function! s:SelectFencedCodeA()
    execute "normal! $?^````*$\<CR>V/^````*$\<CR>o"
endfunction

function! s:SelectFencedCodeI()
    call <SID>SelectFencedCodeA()
    normal! joko
endfunction

" Use fzf-folds instead of :Tags
nnoremap <buffer> <leader>. :Folds<cr>

nmap     <buffer>         ys`      :call <SID>SurroundWithBackticks()<CR>
" nmap     <buffer>         va`      :call <SID>SelectFencedCodeA()<CR>
" nmap     <buffer>         vi`      :call <SID>SelectFencedCodeI()<CR>
" onoremap <buffer><silent> a`       :call <SID>SelectFencedCodeA()<CR>
" onoremap <buffer><silent> i`       :call <SID>SelectFencedCodeI()<CR>

" vim: foldmethod=manual:foldlevel=3
