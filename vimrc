filetype off
try
    call pathogen#runtime_append_all_bundles()
catch
endtry
filetype plugin indent on
syntax on
set nocompatible

" Dynamic settings
" ================

if has("mac")
    " Macintosh
    let g:Tex_ViewRule_pdf='open'
    hi CursorLine term=none cterm=none ctermbg=0
    set cursorline
    set guifont=Menlo:h11
elseif has("win32") || has("win64")
    " Windows
    if filereadable("C:/cygwin/bin/bash.exe")
        set shell=C:\cygwin\bin\bash.exe
    end
    let g:Tex_ViewRule_pdf='start'
    set guifont=Consolas:h10
else
    " Assume Linux
    set t_Co=256         " Let ViM know we have a 256 color capible terminal
    set background=dark  " Light colors
    " Having problems with getting this right. :/
    hi CursorLine term=none cterm=none ctermbg=8
    set cursorline
    colorscheme zenburn
    let g:Tex_ViewRule_pdf='xdg-open'
    set guifont=Monospace\ 10
endif

" if using GUI
if has("gui_running")
    colorscheme wombat
    set guioptions-=T   " No toolbar
    set guioptions-=r   " No scrollbar

    if has("gui_macvim")
      let macvim_hig_shift_movement = 1
    endif

    colorscheme wombat
    try
        set relativenumber
    catch
        set number
    endtry
end

let mapleader=","

" Settings
" ========

set fileformat=unix     " Always UNIX line endings
set fileencoding=utf-8
set visualbell          " don't make noise
set ttyfast

set hidden              " change buffer without saving
try
    set undodir=~/.vim/var/undo/
    set undofile
catch
endtry
set history=300

"set nohlsearch    " don't hilight search matches
set hlsearch      " hilight search matches
set incsearch     " find as you type
set ignorecase    " ignore case in search patterns
set smartcase     " ... unless the pattern has capitals
set gdefault      " use /g as default for s///-expressions

set showmatch     " indicate matching paren in insert mode
set showcmd       " show current uncompleted command
set laststatus=2  " always show status line
set ruler         " Show cursor position
set wildmenu      " Show some autocomplete option in the status bar

set list
set listchars=tab:▸\ ,extends:>,precedes:<,trail:␣

set formatoptions=tcrqn1
set textwidth=80  " sane default?
set wrap
try
    set colorcolumn=85
catch
endtry

set smartindent   " Smarter than autoindent ;)
set tabstop=4     " a tab is four spaces wide
set softtabstop=4 " backspace over softtabs
set shiftwidth=4  " spaces for indent
set expandtab     " spaces, not tabs
set backspace=indent,eol,start

" Read manpages through :Man
so $VIMRUNTIME/ftplugin/man.vim

" Mappings
" ========

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

" Disable arrow keys.
nnoremap <up>    <nop>
nnoremap <down>  <nop>
nnoremap <left>  <nop>
nnoremap <right> <nop>
inoremap <up>    <nop>
inoremap <down>  <nop>
inoremap <left>  <nop>
inoremap <right> <nop>
nnoremap j gj
nnoremap k gk

nnoremap <F1> <ESC>
inoremap <F1> <ESC>
vnoremap <F1> <ESC>

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


" Code completion
" ===============

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


" Autocommands
" ============

au BufRead      *.mail      setfiletype mail
au BufRead      *.safari    setfiletype html
au BufRead      *.tex       nnoremap <C-l> :!texi2pdf %<CR>
au BufRead      *.tex       let g:Tex_DefaultTargetFormat='pdf'

au FocusLost    *           :wa


" Abbreviations
" =============

abbr xdate <c-r>=strftime("%Y-%m-%d")<CR>
abbr xdatetime <c-r>=strftime("%Y-%m-%d %H:%M:%S")<CR>


" Plugins
" =======

let yankring_history_dir=expand("$HOME/.vim/var/yankring/")
let wiki = {}
let wiki.path = '~/.vim/var/vimwiki'
let g:vimwiki_list = [wiki]
