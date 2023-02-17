" ================ General Config ====================

set number
syntax on
set laststatus=2
if has('mouse')
  set mouse=a
endif

set clipboard=unnamed

" ================ Colors ==========================
highlight DiffAdd    ctermfg=black ctermbg=green
highlight DiffDelete ctermfg=black ctermbg=red
highlight DiffChange ctermfg=black ctermbg=blue
highlight DiffText   ctermfg=black ctermbg=magenta

" ================ Hotkeys ==========================

:let mapleader = ","

inoremap jk <Esc>
inoremap kj <Esc>

noremap <Leader>w :w<CR>
noremap <Leader>q :q<CR>
noremap <Leader>wq :wq<CR>

" ================ Indentation ======================

set autoindent
set smartindent
set smarttab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab

" ================ Scrolling ========================

set scrolloff=8         "Start scrolling when we're 8 lines away from margins
set sidescrolloff=15
set sidescroll=1

" ================ Search ===========================

set incsearch       " Find the next match as we type the search
set hlsearch        " Highlight searches by default
set ignorecase      " Ignore case when searching...
set smartcase       " ...unless we type a capital

" ================ Netrw ===========================
let g:netrw_keepdir = 0
let g:netrw_banner = 0
let g:netrw_localcopydircmd = 'cp -r'
let g:netrw_altv = 1
let g:netrw_preview = 1
let g:netrw_winsize= 30
let g:netrw_liststyle = 3

nnoremap <leader>e :Explore<CR>
nnoremap <leader>v :Vexplore<CR>
nnoremap <leader>h :Hexplore!<CR>
