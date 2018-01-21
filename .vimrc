" Set Main Code Directory path based on computer name
let hostname = substitute(system('hostname'), '\n', '', '')
if (hostname == 'VM-Win7Pro')
    let $CODE='E:/Code'
else
    let $CODE='$HOME/Documents/GitRepos'
endif

" Source vimrc files
let $MYVIMRC='$CODE/VIM/.myvimrc'
:so $MYVIMRC

" Placing this string here prevents .myvimrc from getting messed up folding
let fold_marker_string = "{{{"
