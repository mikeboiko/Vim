" Set Main Code Directory path based on computer name
let hostname = substitute(system('hostname'), '\n', '', '')
if (hostname == 'VM-Win7Pro')
    let $CODE='E:/Code'
else
    let $CODE='$HOME/Documents/GitRepos'
endif

" Placing this string here prevents .myvimrc from getting messed up folding
let g:fold_marker_string = "{{{"

" Source main vimrc file
let $MYVIMRC='$CODE/VIM/.myvimrc'
:so $MYVIMRC

" vim: foldmethod=manual:foldlevel=5
