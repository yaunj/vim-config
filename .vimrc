set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-unimpaired'
Plugin 'tpope/vim-eunuch'
Plugin 'tpope/vim-sleuth'
Plugin 'klen/python-mode'

Plugin 'morhetz/gruvbox'
Plugin 'nanotech/jellybeans.vim'

call vundle#end()

filetype plugin indent on
syntax on
let mapleader=","

" Encoding {{{
set fileformat=unix     " Always UNIX line endings
set encoding=utf-8      " Somehow not default under Windows :(
set fileencoding=utf-8

" }}}
" Appearance {{{
colorscheme wombat256i

" if using GUI
if has("gui_running")
    set guioptions-=T   " No toolbar
    set guioptions-=r   " No scrollbar

    if has("mac")
        set guifont=Menlo:h11
    elseif has("win32") || has("win64")
        set guifont=Consolas:h10
    else
        set guifont=Monospace\ 10
    endif

    if has("gui_macvim")
      let macvim_hig_shift_movement = 1
    endif
end

set showmatch     " indicate matching paren in insert mode
set list
set listchars=tab:▸·,extends:>,precedes:<,trail:·,nbsp:·

set cursorline
try
    set colorcolumn=81
catch
endtry

" Statusline {{{
set laststatus=2  " always show status line
set showcmd       " show current uncompleted command
set ruler         " Show cursor position
set wildmenu      " Show some autocomplete option in the status bar

set statusline=
set statusline+=[#%n]          " buffer number
set statusline+=[%Y%M%R%W]\    " filetype and flags
set statusline+=%<%f\          " start truncation here and add filename
set statusline+=%=             " move to right hand side
set statusline+=[%{&fenc},%{&fileformat}]\  " file encoding + format
set statusline+=(%l,%v         " cursor position with byte optional offset
set statusline+=%{col('.')>virtcol('.')?'['.col('.').']':''}
set statusline+=)\ 
set statusline+=%P             " percentage into file
" }}}
" }}}
" Searching {{{
set hlsearch      " hilight search matches
set incsearch     " find as you type
set ignorecase    " ignore case in search patterns
set smartcase     " ... unless the pattern has capitals
set gdefault      " use /g as default for s///-expressions

" }}}
" Indenting {{{
set smartindent   " Smarter than autoindent ;)
set tabstop=8     " length used to display a tab character
set softtabstop=4 " backspace over softtabs
set shiftwidth=4  " spaces for indent
set expandtab     " spaces, not tabs

" }}}
" Formatting and textlength {{{
set formatoptions=
set formatoptions+=t " Autowrap using textwidth
set formatoptions+=c " Autowrap comments, inserting comment leader
set formatoptions+=r " Insert comment leader while in insert mode
set formatoptions+=q " Reformat comments with gq
set formatoptions+=n " Recognize numbered lists

set textwidth=80     " sane default?
set wrap

" }}}
" History and undoing {{{
try
    if has('win32') || has('win64')
        set undodir=~/vimfiles/var/undo/
    else
        set undodir=~/.vim/var/undo/
    endif
    set undofile
catch
endtry
set history=300

" }}}
" Misc settings {{{
" Couldn't fit these in someplace else ...
set visualbell          " don't make noise
set ttyfast
set hidden              " change buffer without saving

set backspace=indent,eol,start

" Read manpages through :Man
so $VIMRUNTIME/ftplugin/man.vim

" }}}
" Code completion {{{
" :help new-omni-completion
" C-x C-o for completion, C-x C-o|n|<Down> for next, C-x C-p|<Up> for prev
" Should have method definitions as well
autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType python set keywordprg=pydoc
autocmd FileType ruby set omnifunc=rubycomplete#Complete
autocmd FileType ruby set keywordprg=ri
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS

" }}}
" Mappings {{{
" Common typos
map :W :w
map :Q :q

" Sensible regexes
nnoremap / /\v
vnoremap / /\v

" Ctrl-tab to correctly indent line in insert mode
inoremap <C-tab> <C-o>V=

" reformat text
nnoremap Q gqap
vnoremap Q gq

" clear hilighting from search
nnoremap <leader><Space> :nohl<CR>

" <leader>p as pastetoggle
nnoremap <leader>p :setlocal paste! paste?<cr>

" Up and down moves through visible lines, not over them.
nnoremap j gj
nnoremap k gk
nnoremap <up> gk
nnoremap <down> gj

" On some keyboards esc is easy to miss
inoremap <F1> <ESC>
vnoremap <F1> <ESC>

" Fast way to normal mode if hands are resting on home row
inoremap jk <ESC>

" clean trailing whitespace
nnoremap <leader>W :%s/\s\+$//<CR>:let @/=''<CR>

" Change tab settings
nnoremap <leader>t2 :setlocal shiftwidth=2 tabstop=2 softtabstop=2
nnoremap <leader>t4 :setlocal shiftwidth=4 tabstop=4 softtabstop=4
nnoremap <leader>t8 :setlocal shiftwidth=8 tabstop=8 softtabstop=8

" Emacs bindings for command line
cnoremap <C-A> <Home>
cnoremap <C-E> <End>
cnoremap <C-K> <C-U>

" Move between windows
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l

" Tabs and buffers
nnoremap <C-Right> :bn<CR>
nnoremap <C-Left>  :bp<CR>
nnoremap <leader>c :bd<CR>
nnoremap <leader>b :buffer 

nnoremap <leader>te :tabedit 
nnoremap <leader>tn :tabnew %<CR>
nnoremap <leader>tc :tabclose<CR>

" }}}
" Settings for plugins {{{
map <leader>g :GundoToggle<CR>

let yankring_history_dir=expand("$HOME/.vim/var/yankring/")
if has("win32") || has("win64")
    let yankring_history_dir=expand("$HOME/vimfiles/var/yankring/")
endif

let wiki = {}
let wiki.path = '~/.vim/var/vimwiki'
if has('win32') || has('win64')
    let wiki.path = '~/vimfiles/var/vimwiki'
endif
let g:vimwiki_list = [wiki]

" }}}
