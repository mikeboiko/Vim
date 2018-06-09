" =======================================================================
" === Description ...: Python Settings
" === Author ........: Mike Boiko
" =======================================================================

" Editor Config {{{1
" Indentation {{{2
setlocal nosmartindent

" Syntax {{{1
" Python Syntax Checker
let g:syntastic_python_checkers = ['pylint']
let python_highlight_all=1

" Virtual Environments {{{1
" Python with virtualenv support
" py << EOF
" import os
" import sys
" if 'VIRTUAL_ENV' in os.environ:
" project_base_dir = os.environ['VIRTUAL_ENV']
" activate_this = os.path.join(project_base_dir,
" 'bin/activate_this.py')
" execfile(activate_this, dict(__file__=activate_this))
" EOF

" Mappings {{{1

" YouCompleteMe
nnoremap <buffer> <leader>d  :YcmCompleter GoToDefinition<CR>
nnoremap <buffer> gd  :YcmCompleter GoToDeclaration<CR>
nnoremap <buffer> <leader>h  :YcmCompleter GetDoc<CR>

