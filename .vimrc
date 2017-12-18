" Set Main Code Directory path based on computer name
let hostname = substitute(system('hostname'), '\n', '', '')
" noremap <leader>iv :echo hostname<CR>
if (hostname == 'Mike-Laptop' || hostname == 'Mike-XPS')
    let $CODE='$HOME/Documents/08 - Programming'
elseif (hostname == 'VM-Win7Pro')
    let $CODE='E:/Code'
else
    let $CODE='$HOME/Documents/GitHub'
endif

" Source custom .vimrc file that is part of GitHub repo
" :so $CODE/Windows/VIM/.myvimrc
let $MYVIMRC='$CODE/Windows/VIM/.myvimrc'
let $FOLDSVIMRC='$CODE/Windows/VIM/folds.vimrc'
:so $MYVIMRC
:so $FOLDSVIMRC
