filetype off
" runtime! autoload/pathogen.vim
" silent! call pathogen#runtime_append_all_bundles()
call pathogen#runtime_append_all_bundles()
" call pathogen#helptags()
syntax on
filetype plugin indent on

" Backups
set backupdir=~/.vim/tmp/backup// " backups
set directory=~/.vim/tmp/swap//   " swap files
set undodir=~/.vim/tmp/undo//     " undo files
set backup                        " enable backups

set nocompatible
set modelines=0

set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

" Color Scheme
set background=dark
" colorscheme solarized
colorscheme molokai

set encoding=utf-8
set scrolloff=3
set autoindent
set showmode
set showcmd
set hidden
set wildmenu
set wildmode=list:longest
set visualbell
set cursorline
set ttyfast
set ruler
set backspace=indent,eol,start
set laststatus=2
" set relativenumber
set undofile

let mapleader = ","

nnoremap / /\v
vnoremap / /\v
set ignorecase
set smartcase
set gdefault
set incsearch
set showmatch
set hlsearch
nnoremap <leader><space> :noh<cr>
nnoremap <tab> %
vnoremap <tab> %

set wrap
set textwidth=79
set formatoptions=qrn1
set colorcolumn=85

nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>
nnoremap j gj
nnoremap k gk

" Folding
set foldenable
set foldlevel=100 " No autofolding
set foldopen=block,hor,mark,percent,quickfix,tag
function SimpleFoldText() " {
    return getline(v:foldstart).' '
endfunction " }
set foldtext=SimpleFoldText() " Custom fold text function 
nnoremap <space> za
vnoremap <space> zf

" Sudo to write
cmap w!! w !sudo tee % >/dev/null

" Stupid colon is too hard. Use semicolon. 
nnoremap ; :

" Save when losing focus
au FocusLost * :wa

" Leader settings
nnoremap <leader>v V
nnoremap <leader>x :x<cr>

" Taglist
" let Tlist_Ctags_Cmd = '/usr/bin/ctags'
nnoremap <leader>tt :TlistToggle<cr>:TlistSessionLoad .tlist<cr>
nnoremap <leader>tl :TlistSessionLoad .tlist<cr>
nnoremap <leader>ts :TlistSessionSave .tlist<cr>
nnoremap <leader>ta :TlistAddFiles *.m<cr>
let Tlist_Exit_OnlyWindow = 1
let Tlist_WinWidth = 50

" Better escape
inoremap jj <ESC>

" Better edit .vimrc
nnoremap <leader>ev <C-w><C-v><C-l>:e $MYVIMRC<cr>

" Split window with <ldr>w. Move with ctrl-hjkl
nnoremap <leader>w <C-w>v<C-w>l
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
