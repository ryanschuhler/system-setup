" ================ General Config ====================

set number                      "Line numbers are good
syntax on
set laststatus=2
if has('mouse')
  set mouse=a
endif

set clipboard=unnamed

" ================ Colors ==========================
highlight DiffAdd    ctermfg=white ctermbg=green
highlight DiffDelete ctermfg=white ctermbg=red
highlight DiffChange ctermfg=white ctermbg=blue
highlight DiffText   ctermfg=white ctermbg=magenta

" ================ Hotkeys ==========================

:let mapleader = ","

inoremap jk <Esc>
inoremap kj <Esc>

nnoremap <leader>cd :lcd %:p:h<CR>
nnoremap <leader>cr :lcd ~/repos<CR>
nnoremap <leader>cw :lcd ~/repos/lfris-www<CR>
nnoremap <Leader>f :Files<CR>
nnoremap <Leader>b :Buffers<CR>
nnoremap <Leader>tn :tabnext<CR>
nnoremap <Leader>tc :tabclose<CR>
nnoremap <Leader>www :Explore ~/repos/lfris-www<CR>
nnoremap <Leader>~ :Explore ~<CR>
noremap <Leader>y "*y
noremap <Leader>p "*p
noremap <Leader>Y "+y
noremap <Leader>P "+p
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

" ================ Plugins ===========================
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

Plugin 'airblade/vim-gitgutter'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-vinegar'

set runtimepath^=~/.vim/bundle/vim-vinegar

set runtimepath^=~/.vim/bundle/ctrlp.vim
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 'c'
