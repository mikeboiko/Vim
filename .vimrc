" Set Main Code Directory path based on computer name
let hostname = substitute(system('hostname'), '\n', '', '')
if (hostname == 'VM-Win7Pro')
    let $CODE='E:/Code'
else
    let $CODE='$HOME/Documents/GitRepos'
endif

" Source main vimrc file
let $MYVIMRC='$CODE/vim/.myvimrc'
:so $MYVIMRC
