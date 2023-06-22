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
  execute "normal! {o```\<ESC>}O```\<ESC>"
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
