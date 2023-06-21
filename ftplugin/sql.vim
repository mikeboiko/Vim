" =======================================================================
" === Description ...: SQL Settings
" === Author ........: Mike Boiko
" =======================================================================

" This is a patch so sql wouldn't have 2 spaces after comment
au BufWinEnter,BufEnter <buffer> let g:NERDSpaceDelims=0
au BufLeave <buffer> let g:NERDSpaceDelims=1

" 2 spaces for tab
autocmd FileType sql setlocal shiftwidth=2 tabstop=2
