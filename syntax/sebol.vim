" Vim syntax file
" Language:     Yokogawa SEBOL
" Author:       Mike Boiko

" Check if there is a previous definition of the sebol language
if exists("b:current_syntax")
  finish
endif

let b:current_syntax = "sebol"

" Important Keywords
syn keyword basicLanguageKeywords PRINT OPEN IF

syn keyword statusChangeKeywords
            \ exit
            \ signal
            \ qsigcancel
            \ isigmask
            \ isigunmask
            \ semlock
            \ semunlock

syn keyword sebolTodo contained TODO FIXME XXX NOTE

" Comments
syn match sebolComment "!.*$" contains=sebolTodo
syn match sebolComment "*.*$" contains=sebolTodo

" Strings
syn region sebolString start='"' end='"' contained

" Define different types of Highlighting
hi def link sebolTodo        Todo
hi def link sebolComment     Comment
hi def link sebolBlockCmd    Statement
hi def link sebolHip         Type
hi def link sebolString      Constant
hi def link sebolDesc        PreProc
hi def link sebolNumber      Constant
