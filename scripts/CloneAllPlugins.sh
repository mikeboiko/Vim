#!/bin/bash
# Enter bash terminal: chmod +x <script name>
# Run Script: ./<script name>
# TODO-MB [180106] - Check if in Linux/Windows and don't create vimfiles folder in Linux
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
    git clone https://github.com/PProvost/vim-ps1.git "$i/vim-ps1"                          # Powershell file types
    git clone https://github.com/PyCQA/pylint.git "$i/pylint"                               # Anaylize python code
    git clone https://github.com/Valloric/YouCompleteMe "$i/youcompleteme"                  # Auto-completion
    git clone https://github.com/Vimjas/vim-python-pep8-indent.git "$i/python-indent"       # PEP8 standard
    git clone https://github.com/godlygeek/tabular "$i/tabular"                             # Align things
    git clone https://github.com/junegunn/gv.vim.git "$i/gv-vim"                            # Access git files easier
    git clone https://github.com/kien/ctrlp.vim "$i/ctrlp"                                  # Browse recent/project files
    git clone https://github.com/majutsushi/tagbar "$i/tagbar"                              # Use c-tags in real time and display tag bar
    git clone https://github.com/mattn/emmet-vim "$i/emmet-vim"                             # Edit HTML/CSS quickly
    git clone https://github.com/nathanaelkane/vim-indent-guides.git "$i/vim-indent-guides" # Visual indent levels
    git clone https://github.com/posva/vim-vue "$i/vim-vue"                                 # Vue filetype recognition
    git clone https://github.com/scrooloose/nerdcommenter "$i/nerdcommenter"                # Commenting
    git clone https://github.com/scrooloose/nerdtree "$i/nerdtree"                          # Tree file browser
    git clone https://github.com/tpope/vim-dispatch "$i/vim-dispatch"                       # Asynchronous compilation/commands
    git clone https://github.com/tpope/vim-fugitive "$i/vim-fugitive"                       # Git wrapper
    git clone https://github.com/tpope/vim-repeat "$i/vim-repeat"                           # Repeat surround and commenting with .
    git clone https://github.com/tpope/vim-surround "$i/vim-surround"                       # Surround all the stuff
    git clone https://github.com/vim-airline/vim-airline "$i/vim-airline"                   # Nice status bar
    git clone https://github.com/jiangmiao/auto-pairs "$i/auto-pairs"                       # Auto-close brackets

done

# TODO-MB [180106] - Only perform on Windows
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

# YouCompleteMe
cd ~/.vim/bundle/youcompleteme
git submodule update --init --recursive
./install.py --js-completer

# # Configure Pylint
# if [ ! -d "$HOME/vimfiles/bundle/pylint" ]; then
    # cd ~/vimfiles/bundle/pylint
    # python ./setup.py install
# fi

# echo ${MyFilePath[0]}
# echo ${MyFilePath[1]}

read -p "$*"
