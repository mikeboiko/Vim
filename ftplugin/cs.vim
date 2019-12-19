" ===================================================================
" === Description ...: C# Settings
" === Author ........: Mike Boiko
" ===================================================================

" Notes {{{1
" Dispatch
" Compile Asynchronously :Make
" Run Program Asynchronously :Start C:\Users\Mike\Documents\GitRepos\AccuTune\AccuTuneMain\AccuTune\bin\Release\AccuTune.exe -wait=never --unlockApp -t python --log

" Settings {{{1

" Set properties for MsBuild compilation
setlocal errorformat=\ %#%f(%l\\\,%c):\ %m
setlocal makeprg=MSBuild.exe\ /nologo\ /v:q\ /p:Configuration=Release
" TODO-MB [180723] - To properly parse paths, use full paths and build externally, dump logfile and parse in vim with :cfile after running wslpath for converting from Windows to Unix paths
" setlocal makeprg=MSBuild.exe\ /nologo\ /v:q\ /property:GenerateFullPaths=true\ /p:Configuration=Release

" Compile C# project and Run the exe if there are no errors
function! CompileCsharp()

    " Synchronous compile
    silent make!

    let g:qfListHeight = min([ g:maxQFlistRecords, len(getqflist()) ])

    if (len(filter(getqflist(), 'v:val.text =~ "error"')) == 0)
        " Run Asynchronously - keep focus on vim
        silent exe trim("terminal ".g:term_close." ++rows=15 ".b:startapp.b:startfile." ".b:startargs)
        cclose
    else
        " Open QF window
        exe 'top ' . g:qfListHeight . ' copen'
    endif

    redraw!

    return
endfunction

" Compile and Run C# Application
nnoremap <buffer> <leader>rr :wa<CR>:call CompileCsharp()<CR>

" Mappings {{{1

nnoremap <buffer> gd zR:OmniSharpGotoDefinition<CR>
nnoremap <buffer> <leader>h :OmniSharpDocumentation<CR>

" Project Specific {{{1
" AccuTuneMain " {{{2
" Save all files, compile and open AccuTune.exe
au BufWinEnter,BufEnter */AccuTune/Main/*
            \ let b:startapp='' |
            \ let b:startfile=$HOME.'/Documents/GitRepos/AccuTune/Main/AccuTune/bin/Release/AccuTune.com' |
            \ let b:startargs='--unlockApp -t Simulink.Device1.Python -s Kepware.KEPServerEX.V5 --log'

" AccuTuneDocDump " {{{2
" AccuTune Documentation/ScreenCapture
au BufWinEnter,BufEnter */AccuTune/Docs/*
            \ let b:startapp='' |
            \ let b:startfile=$HOME.'/Documents/GitRepos/AccuTune/Docs/AccuTune/Docs/ScreenCapture/ScreenCapture/bin/Release/ScreenCapture.exe' |
            \ let b:startargs=''

" AccuTuneTests " {{{2
" AccuTune Automated Tests
au BufWinEnter,BufEnter */AccuTune/Tests/*
            \ let b:startapp='' |
            \ let b:startfile=$HOME.'/Documents/GitRepos/AccuTune/Tests/Tests/bin/Release/Tests.exe' |
            \ let b:startargs=''

