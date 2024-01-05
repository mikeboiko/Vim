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
        " TODO-MB [220408] - Switch to vim-flow
        " silent exe trim("terminal ".g:term_close." ++rows=15 ".b:startapp.b:startfile." ".b:startargs)
        cclose
    else
        " Open QF window
        exe 'top ' . g:qfListHeight . ' copen'
    endif

    redraw!

    return
endfunction

" Functions {{{1

function! s:DotNetDebug(path)
  wa
  let buffer_name ='*/*dotnet-test.sh*'
  let buffer_number = bufnr(buffer_name)
  if buffer_number > 0
    tabprevious
    silent! exe 'bdelete! '. buffer_number
  endif
  silent! exe 'tabe term://~/git/Work/CT/scripts/dotnet-test.sh true false \"' . a:path .'\" \| tee /tmp/dotnet-test.log'
endfunction

" Mappings {{{1

" nnoremap <buffer> <leader>rr :wa<CR>:call CompileCsharp()<CR>
nnoremap <buffer> <leader>fi :OmniSharpCodeFormat<CR>
nnoremap <buffer> <leader>h :OmniSharpDocumentation<CR>
nnoremap <buffer> gd zR:OmniSharpGotoDefinition<CR>

nnoremap <buffer> <leader>dr :call <SID>DotNetDebug(expand('%:p:h'))<CR>

" Project Specific {{{1
" AccuTuneMain " {{{2
" Save all files, compile and open AccuTune.exe
au BufWinEnter,BufEnter */AccuTune/Main/*
            \ let b:startapp='' |
            \ let b:startfile=$HOME.'/git/AccuTune/Main/AccuTune/bin/Release/AccuTune.com' |
            \ let b:startargs='--unlockApp -t Simulink.Device1.Python -s Kepware.KEPServerEX.V5 --log'

" AccuTuneDocDump " {{{2
" AccuTune Documentation/ScreenCapture
au BufWinEnter,BufEnter */AccuTune/Docs/*
            \ let b:startapp='' |
            \ let b:startfile=$HOME.'/git/AccuTune/Docs/AccuTune/Docs/ScreenCapture/ScreenCapture/bin/Release/ScreenCapture.exe' |
            \ let b:startargs=''

" AccuTuneTests " {{{2
" AccuTune Automated Tests
au BufWinEnter,BufEnter */AccuTune/Tests/*
            \ let b:startapp='' |
            \ let b:startfile=$HOME.'/git/AccuTune/Tests/Tests/bin/Release/Tests.exe' |
            \ let b:startargs=''
