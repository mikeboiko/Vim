" =======================================================================
" === Description ...: Python Settings
" === Author ........: Mike Boiko
" =======================================================================

" Editor Config {{{1
" Commenting {{{2
" This is a patch so python wouldn't have 2 spaces after comment
au BufWinEnter,BufEnter <buffer> let g:NERDSpaceDelims=0
au BufLeave <buffer> let g:NERDSpaceDelims=1
" TODO-MB [170830] - When I source vim while I'm in a python buffer, I need to
" leave the buffer and come back to it to avoid the double spaces

" Indentation {{{2
setlocal nosmartindent

" Syntax {{{1
" Python Syntax Checker
let g:syntastic_python_checkers = ['pylint']
let python_highlight_all=1

" Running Script {{{1

au BufWinEnter,BufEnter <buffer> map <buffer> <leader>rr :wa<CR>:silent exe "Start python ".@%." "b:start<CR>

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
