" =======================================================================
" === Description ...: Markdown Settings
" === Author ........: Mike Boiko
" =======================================================================

" Auto Format Document for Folding
function! FormatMDFunc()
    g/^#\s\(.*-->\)\@!/norm! A <!-- {{{1 -->
    g/^##\s\(.*-->\)\@!/norm! A <!-- {{{2 -->
    g/^###\s\(.*-->\)\@!/norm! A <!-- {{{3 -->
endfunction
nnoremap <buffer> <c-s> :silent call FormatMDFunc()<CR>:noh<CR>:w<CR>

" Fix red highlighting when there's an _ in a word
syn match markdownError "\w\@<=\w\@="

" Turn on spell-check
" setlocal spell

" vim: foldmethod=manual:foldlevel=3
