#!/bin/bash
# Enter bash terminal: chmod +x <script name>
# Run Script: ./<script name>
MyFilePath[0]=~/.vim/bundle
MyFilePath[1]=~/vimfiles/bundle

if [ ! -d "$HOME/.vim/bundle" ]; then
    mkdir $HOME/.vim/bundle
fi
if [ ! -d "$HOME/vimfiles/bundle" ]; then
    mkdir $HOME/vimfiles/bundle
fi

if [ ! -d "$HOME/.vim" ]; then
    git clone https://github.com/tpope/vim-pathogen ~/.vim
    git clone https://github.com/tpope/vim-pathogen ~/vimfiles
fi

# Loop through array and clone vim plugins into .vim and vimfiles directories
for i in "${MyFilePath[@]}"
do

    # git clone --depth=1 https://github.com/vim-syntastic/syntastic "$i/syntastic"
    echo item: $i
    git clone https://github.com/PProvost/vim-ps1.git "$i/vim-ps1"
    git clone https://github.com/PyCQA/pylint.git "$i/pylint"
    git clone https://github.com/Valloric/YouCompleteMe "$i/youcompleteme"
    git clone https://github.com/Vimjas/vim-python-pep8-indent.git "$i/python-indent"
    git clone https://github.com/godlygeek/tabular "$i/tabular"
    git clone https://github.com/junegunn/gv.vim.git "$i/gv-vim"
    git clone https://github.com/kien/ctrlp.vim "$i/ctrlp"
    git clone https://github.com/majutsushi/tagbar "$i/tagbar"
    git clone https://github.com/nathanaelkane/vim-indent-guides.git "$i/vim-indent-guides"
    git clone https://github.com/posva/vim-vue "$i/vim-vue"
    git clone https://github.com/scrooloose/nerdcommenter "$i/nerdcommenter"
    git clone https://github.com/scrooloose/nerdtree "$i/nerdtree"
    git clone https://github.com/tpope/vim-dispatch "$i/vim-dispatch"
    git clone https://github.com/tpope/vim-fugitive "$i/vim-fugitive"
    git clone https://github.com/tpope/vim-repeat "$i/vim-repeat"
    git clone https://github.com/tpope/vim-surround "$i/vim-surround"
    git clone https://github.com/vim-airline/vim-airline "$i/vim-airline"

done

# Configure YouCompleteMe
if [ ! -d "$HOME/ycm_build" ]; then
    cd ~/vimfiles/bundle/youcompleteme
    git submodule update --init --recursive
    cd ~
    mkdir ycm_build
    cd ycm_build
    # Visual Studio 2017 packages need to be installed first (not sure which ones)
    cmake -G "Visual Studio 15 Win64" . ~/vimfiles/bundle/YouCompleteMe/third_party/ycmd/cpp
    cmake --build . --target ycm_core --config Release
	cd ~/vimfiles/bundle/youcompleteme
    python install.py --omnisharp-completer
fi

# Configure Pylint
if [ ! -d "$HOME/vimfiles/bundle/pylint" ]; then
    cd ~/vimfiles/bundle/pylint
    python ./setup.py install
fi

# echo ${MyFilePath[0]}
# echo ${MyFilePath[1]}

read -p "$*"
