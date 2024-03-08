" =======================================================================
" === Description ...: Vim Settings
" === Author ........: Mike Boiko
" =======================================================================

" Use fzf-folds instead of CtrlP
nnoremap <buffer> <leader>. :Folds<cr>
setlocal foldmethod=marker

" Pull up help for word under cursor in a new tab
nnoremap <buffer> <expr> <leader>h ":help " . expand("<cword>") . "\n"

" vim: foldmethod=manual:foldlevel=3
