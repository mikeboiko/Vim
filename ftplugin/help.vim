" Pull up help for word under cursor in a new tab
nnoremap <buffer> <expr> <leader>h ":help " . expand("<cword>") . "\n"
