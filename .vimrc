" Set Main Code Directory path based on computer name
let hostname = substitute(system('hostname'), '\n', '', '')
if (hostname == 'VM-Win7Pro')
    let $CODE='E:/Code'
else
    let $CODE='$HOME/Documents/GitRepos'
endif

" Source vimrc files
let $MYVIMRC='$CODE/VIM/.myvimrc'
let $FOLDSVIMRC='$CODE/VIM/folds.vimrc'
:so $MYVIMRC
:so $FOLDSVIMRC
