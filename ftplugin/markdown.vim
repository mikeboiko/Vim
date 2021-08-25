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

" Use fzf-folds instead of CtrlP
nnoremap <buffer> <leader>. :Folds<cr>

" vim: foldmethod=manual:foldlevel=3
