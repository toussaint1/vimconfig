set nocompatible
let mapleader = ","
source $VIMRUNTIME/vimrc_example.vim
source $VIMRUNTIME/mswin.vim
behave mswin

" Compare function
set diffexpr=MyDiff()
function! MyDiff()
  let opt = '-a --binary '
  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  let arg1 = v:fname_in
  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
  let arg2 = v:fname_new
  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
  let arg3 = v:fname_out
  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
  if $VIMRUNTIME =~ ' '
    if &sh =~ '\<cmd'
      if empty(&shellxquote)
        let l:shxq_sav = ''
        set shellxquote&
      endif
      let cmd = '"' . $VIMRUNTIME . '\diff"'
    else
      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
    endif
  else
    let cmd = $VIMRUNTIME . '\diff'
  endif
  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3
  if exists('l:shxq_sav')
    let &shellxquote=l:shxq_sav
  endif
endfunction

" XML formatter
function! DoFormatXML() range
  " Save the file type
  let l:origft = &ft
  
  " Clean the file type
  set ft=
  
  " Add fake initial tag (so we can process multiple top-level elements)
  exe ":let l:beforeFirstLine=" . a:firstline . "-1"
  if l:beforeFirstLine < 0
  	let l:beforeFirstLine=0
  endif
  exe a:lastline . "put ='</PrettyXML>'"
  exe l:beforeFirstLine . "put ='<PrettyXML>'"
  exe ":let l:newLastLine=" . a:lastline . "+2"
  if l:newLastLine > line('$')
  	let l:newLastLine=line('$')
  endif
  
  " Remove XML header
  exe ":" . a:firstline . "," . a:lastline . "s/<\?xml\\_.*\?>\\_s*//e"
  
  " Recalculate last line of the edited code
  let l:newLastLine=search('</PrettyXML>')
  
  " Execute external formatter
  exe ":silent " . a:firstline . "," . l:newLastLine . "!xmllint --noblanks --format --recover -"
  
  " Recalculate first and last lines of the edited code
  let l:newFirstLine=search('<PrettyXML>')
  let l:newLastLine=search('</PrettyXML>')
  
  " Get inner range
  let l:innerFirstLine=l:newFirstLine+1
  let l:innerLastLine=l:newLastLine-1
  
  " Remove extra unnecessary indentation
  exe ":silent " . l:innerFirstLine . "," . l:innerLastLine "s/^  //e"
  
  " Remove fake tag
  exe l:newLastLine . "d"
  exe l:newFirstLine . "d"
  
  " Put the cursor at the first line of the edited code
  exe ":" . l:newFirstLine
  
  " Restore the file type
  exe "set ft=" . l:origft
endfunction
command! -range=% FormatXML <line1>,<line2>call DoFormatXML()

set langmenu=en_US
let $LANG = 'en_US'
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim

" encodings
set encoding=utf-8
set fileencoding=utf-8

" color scheme
colorscheme janah
" do not store global and local values in a session
set ssop-=options
" do not store folds
set ssop-=folds
" splits
set splitbelow
set splitright

" Always show the status line
set laststatus=2

set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove left-hand scroll bar

set number

"Pathogen
execute pathogen#infect()
syntax on
filetype plugin indent on

" au GUIEnter * simalt ~x

" This allows buffers to be hidden if you've modified a buffer.
" This is almost a must if you wish to use buffers in this way.
set hidden

" Don't wrap words
set nowrap

" To open a new empty buffer
" This replaces :tabnew which I used to bind to this mapping
nmap <leader>T :enew<cr>

" Move to the next buffer
nmap <leader>l :bnext<CR>

" Move to the previous buffer
nmap <leader>h :bprevious<CR>

" Close the current buffer and move to the previous one
" This replicates the idea of closing a tab
nmap <leader>bq :bp <BAR> bd #<CR>

" Wipe the current buffer and move to the previous one
" This replicates the idea of closing a tab
nmap <leader>bww :bp <BAR> bd! #<CR>

" Show all open buffers and their status
nmap <leader>bl :ls<CR>

" CtrlP

" Setup some default ignores
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](\.(git|hg|svn)|\_site)$',
  \ 'file': '\v\.(exe|so|dll|class|png|jpg|jpeg)$',
\}

" Use the nearest .git directory as the cwd
" This makes a lot of sense if you are working on a project that is in version
" control. It also supports works with .svn, .hg, .bzr.
let g:ctrlp_working_path_mode = '0'

let g:ctrlp_max_files=50000

" Use a leader instead of the actual named binding
nmap <leader>p :CtrlP<cr>

" Easy bindings for its various modes
nmap <leader>bb :CtrlPBuffer<cr>
nmap <leader>bm :CtrlPMixed<cr>
nmap <leader>bs :CtrlPMRU<cr>

" Airline config

" Enable the list of buffers
let g:airline#extensions#tabline#enabled = 1

" Show just the filename
let g:airline#extensions#tabline#fnamemod = ':t'

" Buffergator config

" Use the right side of the screen
let g:buffergator_viewport_split_policy = 'n'

" I want my own keymappings...
let g:buffergator_suppress_keymaps = 1

" Looper buffers
"let g:buffergator_mru_cycle_loop = 1

" Go to the previous buffer open
nmap <leader>jj :BuffergatorMruCyclePrev<cr>

" Go to the next buffer open
nmap <leader>kk :BuffergatorMruCycleNext<cr>

" View the entire list of buffers open
nmap <leader>bl :BuffergatorOpen<cr>

" Shared bindings from Solution #1 from earlier
nmap <leader>T :enew<cr>
nmap <leader>vt :vnew<cr>
nmap <leader>st :new<cr>
nmap <leader>bq :bp <BAR> bd #<cr>
nmap <leader>bww :bp <BAR> bd! #<cr>

" Close all the buffers
map <leader>ba :1,$bd!<cr>

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

noremap <silent> <F7> :let @*=expand("%:p")<CR>

" Set ignorecase shortcut
nmap <F8> :set ignorecase! ignorecase?<cr>

" run file
:nnoremap <silent> <F9> :!start cmd /c "%:p" & pause<CR>
:nnoremap <silent> <F10> :!python "%:p"

" set clipboard=unnamed
set ignorecase

set backupdir=$VIMRUNTIME/temp//
set directory=$VIMRUNTIME/temp//

" Other
" clean BOM - first remove lines with comments and then remove ''
nmap <leader>bc :silent! g/^.\{-}\/\/.\{-}"/d <ENTER><BAR>:%s/^.\{-}"\(.\{-}\)".\{-}$/\1/g<cr>
