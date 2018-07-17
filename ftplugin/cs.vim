" ===================================================================
" === Description ...: C# Settings
" === Author ........: Mike Boiko
" ===================================================================

" Notes {{{1
" Dispatch
" Compile Asynchronously :Make
" Run Program Asynchronously :Start C:\Users\Mike\Documents\GitRepos\AccuTune\AccuTuneMain\AccuTune\bin\Release\AccuTune.exe -wait=never --unlockApp -t python --log

" Mappings {{{1

" Go to definition/declaration
nnoremap <buffer> gd  :YcmCompleter GoToDefinitionElseDeclaration<CR>

" Settings {{{1

" Set properties for MsBuild compilation
setlocal errorformat=\ %#%f(%l\\\,%c):\ %m
setlocal makeprg=msbuild\ /nologo\ /v:q\ /property:GenerateFullPaths=true\ /p:Configuration=Release

" Compile C# project and Run the exe if there are no errors
function! CompileCsharp()
    silent make!

    let g:qfListHeight = min([ g:maxQFlistRecords, len(getqflist()) ])

    if (len(filter(getqflist(), 'v:val.text =~ "error"')) == 0)
        " Run Asynchronously - keep focus on vim
        silent Start
        cclose
    else
        " Open QF window
        exe 'top ' . g:qfListHeight . ' copen'
    endif

    return
endfunction

" Compile and Run C# Application
" TODO-MB [180714] - Fixup this function properly
" nnoremap <buffer> <leader>rr :wa<CR>:call CompileCsharp()<CR>
" nnoremap <buffer> <leader>rr :wa<CR>:term ++close bash -c "cd ~/Documents/GitRepos/AccuTune/Main; powershell.exe ./AccuTest.ps1"<CR>
nnoremap <buffer> <leader>rr :wa<CR>:term ++close bash -c "cd ~/Documents/GitRepos/AccuTune/Main; powershell.exe ./AccuTest.ps1 --decryptedLog"<CR>

" Project Specific {{{1
" AccuTuneMain " {{{2
" Save all files, compile and open AccuTune.exe
au BufWinEnter,BufEnter */AccuTune/Main/* let b:start='C:\Users\Mike\Documents\GitRepos\AccuTune\Main\AccuTune\bin\Release\AccuTune.com --unlockApp -t Simulink.Device1.Python -s Kepware.KEPServerEX.V5 --log'

" AccuTuneLogs " {{{2
" Save all files, compile and open AccuTune.exe
au BufWinEnter,BufEnter */AccuTune/Logs/* let b:start='C:\Users\Mike\Documents\GitRepos\AccuTune\Logs\LogDecrypt\LogDecrypt\bin\Release\LogDecrypt.exe'

" AccuTuneTests " {{{2
" AccuTune Automated Tests
au BufWinEnter,BufEnter */AccuTune/Tests/* let b:start='C:\Users\Mike\Documents\GitRepos\AccuTune\Tests\Tests\bin\Release\Tests.exe'

