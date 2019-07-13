" =======================================================================
" === Description ...: Python Settings
" === Author ........: Mike Boiko
" =======================================================================

" Editor Config {{{1
" Indentation {{{2
setlocal nosmartindent
setlocal foldmethod=manual

" Mappings {{{1

" YouCompleteMe
nnoremap <buffer> <leader>d  :YcmCompleter GoToDefinition<CR>
nnoremap <buffer> gd  :YcmCompleter GoToDeclaration<CR>
nnoremap <buffer> <leader>h  :YcmCompleter GetDoc<CR>

" TODO-MB [180620] - Finishup dynamic doc function. It should only show doc if it exists
" inoremap ( (<ESC>:YcmCompleter GetDoc<CR>a
