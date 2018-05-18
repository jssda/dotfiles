"===============================================================================
" General Settings

" Inform that the script is written in UTF-8 (including special characters)
set encoding=utf-8
scriptencoding utf-8

if has('nvim')
    let $VIMHOME = expand('~/.config/nvim/')
else
    let $VIMHOME = expand('~/.vim/')
endif

" Use Vim settings instead of vi settings.
set nocompatible

" Set how many lines of history VIM has to remember
if &history < 1000
  set history=1000
endif

if &tabpagemax < 50
  set tabpagemax=50
endif

" Enable filetype plugins
filetype plugin indent on

" Set to auto read when a file is changed from the outside
set autoread

" Set map leader
let mapleader = "\<Space>"
let g:mapleader = "\<Space>"

" Show line number
set nu

" don't treat numbers as octal when performing Ctrl-A and Ctrl-X
set nrformats-=octal

" enable mouse support
set mouse=a
"----------------------------------------------------------------------
" VIM user interface

" Turn on the WiLd menu
set wildmenu
set wildmode=longest,list,full

" Ignore compiled files
set wildignore+=*.o,*~,*.pyc
"set wildignore+=*/.git/*,*/.hg/*,*/.svn/*

" Always show current position
set ruler

" A buffer becomes hidden when it is abandoned
set hid

" Congifure backspace so it acts as it should act
set backspace=eol,start,indent

" When searching try to be smart about cases
set ignorecase
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw

" Show matching brackets when text indicator is over them
set showmatch
" How many tenths of a second to blink when matching brackets
set mat=2

" Show cursor line
set cursorline

" Always show the status line
set laststatus=2
"set stl=%F%y%m\ [%l,%c,%p%%]\ [%n/%{len(filter(range(1,bufnr('$')),'buflisted(v:val)'))}]

" disable syntax highlighting for lone lines
set synmaxcol=200

" set showtabline=2
set completeopt=longest,menuone,preview

" neovim >= 0.17, preview the substitution like :%s/foo/bar/g
if exists('&inccommand')
    set inccommand=nosplit
endif

"----------------------------------------------------------------------
" Files, backups and undo

" Set possible file encodings
"set fileencodings=ucs-bom,utf-8,cp936,gb18030,utf-16,big5,euc-jp,euc-kr,latin1
set fileencodings=ucs-bom,utf-8,cp932,cp936,gb18030,big5,euc-jp,euc-kr,latin1

" Use Unix as the standard file type
set ffs=unix,dos,mac

" Change backup directory to a less annoying place under linux.
if has("unix")
    if isdirectory($HOME.'/.vim-backup') == 0
        :silent !mkdir -p ~/.vim-backup > /dev/null 2>&1
    endif
    set backupdir-=.
    set backupdir+=.
    set backupdir-=~/
    set backupdir^=~/.vim-backup
    set backupdir^=./.vim-backup

    if isdirectory($HOME.'/.vim-swap') == 0
        :silent !mkdir -p ~/.vim-swap > /dev/null 2>&1
    endif
    set directory=./.vim-swap//
    set directory+=~/.vim-swap//
    set directory+=~/tmp//
    set directory+=.

    if exists('+undofile')
        if isdirectory($HOME.'/.vim-undo') == 0
            :silent !mkdir -p ~/.vim-undo > /dev/null 2>&1
        endif

        set undodir=./.vim-undo//
        set undodir+=~/.vim-undo//
        set undofile
    endif
endif

"----------------------------------------------------------------------
" Text, tab and indent related

" Use spaces instead of tabs
set expandtab

" Be smart when using tabs
set smarttab

" 1 tab == 8 spaces
set tabstop=8
set shiftwidth=4
set softtabstop=4
set textwidth=78

set ai " Auto Indent
set si " Smart indent
set wrap " Wrap lines
set cinoptions=l1,t0,g0,(0,Ws

" Dictionary completion
set dictionary+=/usr/share/dict/words

"----------------------------------------------------------------------
" Moving around, tabs, windows and buffers

" Treat long lines as break lines(like emacs)
noremap j gj
noremap gj j
noremap k gk
noremap gk k

" swap these too because ' is easier to type and ` is what I want
noremap ' `
noremap ` '

" Close current buffer
" need vim-bbye
nmap <leader>q :Bdelete<cr>

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif

au FileType crontab setlocal backupcopy=yes

"----------------------------------------------------------------------
" Misc Maps & Functions(for convenience)

" Remove the Windows ^M - when the encodings gets messed up
nnoremap <Leader>mm mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" strip the spaces at the end of line
nnoremap <leader><Space><Space> :%s/\s\+$//<cr>:<C-u>nohlsearch<CR>

" merge multiple continuous lines into one.
nmap <leader><cr> :%s/\(^[[:blank:]]*\n\)\{2,}/\r/<cr>

" quick access to system's clipboard
vmap <leader>y "+y
vmap <leader>Y "+Y
vmap <leader>d "+d
vmap <leader>p "+p
vmap <leader>P "+P
nmap <leader>p "+p
nmap <leader>P "+P

" quick save
nmap <leader>w :w<CR>:<C-u>nohlsearch<CR>:echo<CR>

" execute macro on every selected/visual lines
xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>

function! ExecuteMacroOverVisualRange()
  echo "@".getcmdline()
  execute ":'<,'>normal @".nr2char(getchar())
endfunction

"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function! Zoom ()
    " check if is the zoomed state (tabnumber > 1 && window == 1)
    if tabpagenr('$') > 1 && tabpagewinnr(tabpagenr(), '$') == 1
        let l:cur_winview = winsaveview()
        let l:cur_bufname = bufname('')
        tabclose

        " restore the view
        if l:cur_bufname == bufname('')
            call winrestview(cur_winview)
        endif
    else
        tab split
    endif
endfunction

nmap <leader>z :call Zoom()<CR>

"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Interleave lines, do not support overlapping
" Usage: 90, 100call Interleave(1)
function! Interleave(where) range
    let l:where = a:where

    let l:pos = getpos(l:where)
    if l:where =~ "^'" && !empty(l:pos)
        let l:where = l:pos[1]
    endif

    let l:start = a:firstline
    let l:end = a:lastline

    if l:start < a:where
        for i in range(0, l:end - l:start)
            execute l:start . 'm' . (l:where + i)
        endfor
    else
        for i in range(l:end - l:start, 0, -1)
            execute l:end . 'm' . (l:where + i)
        endfor
    endif
endfunction

" Usage: 90,100Interleave 10
" or     '<,'>Interleave 'a  " will use mark 'a as the target
command! -nargs=1 -range Interleave <line1>,<line2>call Interleave("<args>")
vmap <leader>j :Interleave<space>

"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"Author: Tim Dahlin
function! QuickFixOpenAll()
    if empty(getqflist())
        return
    endif
    let s:prev_val = ""
    for d in getqflist()
        let s:curr_val = bufname(d.bufnr)
        if (s:curr_val != s:prev_val)
            exec "edit " . s:curr_val
        endif
        let s:prev_val = s:curr_val
    endfor
endfunction

command! QuickFixOpenAll call QuickFixOpenAll()

"===============================================================================
" Settings for Programming

"----------------------------------------------------------------------
" Extra Settings

set formatoptions=tclqronmM
if v:version > 703 || v:version == 703 && has("patch541")
  set formatoptions+=j " Delete comment character when joining commented lines
endif

" Path extra will enable Up/downwards search in 'path' and 'tags'
if has('path_extra')
  setglobal tags-=./tags tags-=./tags; tags^=./tags;
endif

" Load matchit.vim, but only if the user hasn't installed a newer version.
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif

"----------------------------------------------------------------------
" Extra Mappings

" borrowed from vim-unimpaired
nmap <silent> [a :prev<CR>
nmap <silent> ]a :next<CR>
nmap <silent> [A :first<CR>
nmap <silent> ]A :last<CR>

" buffer related
nmap <silent> [b :bprev<CR>
nmap <silent> ]b :bnext<CR>
nmap <silent> [B :bfirst<CR>
nmap <silent> ]B :blast<CR>

" quickfix related
nmap <silent> [q :cprev<CR>
nmap <silent> ]q :cnext<CR>
nmap <silent> [Q :cfirst<CR>
nmap <silent> ]Q :clast<CR>
nmap <silent> [l :lprev<CR>
nmap <silent> ]l :lnext<CR>
nmap <silent> [L :lfirst<CR>
nmap <silent> ]L :llast<CR>

" tab related
nmap <silent> [t :tabprev<CR>
nmap <silent> ]t :tabnext<CR>
nmap <silent> [T :tabfirst<CR>
nmap <silent> ]T :tablast<CR>

" disable highlight search for current search
nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>

" visual mode: star-search
xnoremap * :<C-u>call <SID>VSetSearch()<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call <SID>VSetSearch()<CR>?<C-R>=@/<CR><CR>

function! s:VSetSearch()
    let tmp = @s
    norm! gv"sy
    let @/ = '\V' . substitute(escape(@s, '/\'), '\n', '\\n', 'g')
    let @s = tmp
endfunction

" Repeating last substitution
nnoremap & :&&<CR>
xnoremap & :&&<CR>

" select last pasted texts
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

" Search in a Region
vnoremap / <Esc>/\%><C-R>=line("'<")-1<CR>l\%<<C-R>=line("'>")+1<CR>l
vnoremap ? <Esc>?\%><C-R>=line("'<")-1<CR>l\%<<C-R>=line("'>")+1<CR>l

" Scroll without moving cursor screen line
nnoremap <C-J> <C-E>j
vnoremap <C-J> <C-E>j
nnoremap <C-K> <C-Y>k
vnoremap <C-K> <C-Y>k

"----------------------------------------------------------------------
" Show tabs (indent lines)

" | ¦ ┆ ┊ │
let show_tabs=0
if show_tabs == 1
    if &encoding ==? "utf-8"
        set list
        set listchars=tab:\│\ ,trail:~
    else
        set list
        set listchars=tab:>-,trail:~
    endif
endif

"===============================================================================
" settings for manually installed plugins

"----------------------------------------------------------------------
" vimim

if has ("win32")
    set guifont=Courier_New:h12:w7
    set guifontwide=NSimSun-18030,NSimSun
endif

"===============================================================================
" package manager settings
let package_manager = "vim-plug"

if package_manager == "vim-plug"
    call plug#begin($VIMHOME . 'plugged')

    "------------------------------------------------------------------
    " Enhance Basic functionality
    "------------------------------------------------------------------
    Plug 'altercation/vim-colors-solarized'

    Plug 'moll/vim-bbye'
    Plug 'junegunn/vim-easy-align', {'on': '<Plug>(EasyAlign)'}
    Plug 'ervandew/supertab'    " you'll need it
    Plug 'easymotion/vim-easymotion', {'on': ['<Plug>(easymotion-s)', '<Plug>(easymotion-F)', '<Plug>(easymotion-bd-jk)']}

    Plug 'majutsushi/tagbar'
    Plug 'lvht/tagbar-markdown', {'for': 'markdown'}
    " Plug 'ludovicchabant/vim-gutentags' " Generate tags automatically

    Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
    Plug 'Xuyuanp/nerdtree-git-plugin'

    " powerline alternative; for better status line
    Plug 'bling/vim-airline'
    Plug 'vim-airline/vim-airline-themes'

    Plug 'terryma/vim-expand-region'

    Plug 'sbdchd/neoformat', {'on': 'Neoformat'} " enhance the format function (press '=' key)

    Plug 't9md/vim-choosewin', {'on': '<Plug>(choosewin)'}

    Plug 'sjl/gundo.vim', {'on': 'GundoToggle'}

    Plug 'Raimondi/delimitMate' " insert closing quotes, parenthesis, etc. automatically

    Plug 'mhinz/vim-startify'

    Plug 'kana/vim-textobj-user'

    Plug 'tpope/vim-abolish' " Enhance

    Plug 'vim-scripts/LargeFile' " disable some features for faster opening large files.

    Plug 'schickling/vim-bufonly' " close all buffers except current one
    Plug 'kshenoy/vim-signature' " show sign for native marks
    "Plug 'tpope/vim-apathy'

    "------------------------------------------------------------------
    " Integration with Linux environment
    "------------------------------------------------------------------
    Plug 'lotabout/slimux', {'on': ['SlimuxREPLSendLine', 'SlimuxREPLSendSelection'],
                \ 'for': 'python'}
    Plug 'kana/vim-fakeclip'

    Plug 'lotabout/skim', { 'dir': '~/.skim', 'do': './install' }
    Plug 'lotabout/skim.vim'
    "Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
    "Plug 'junegunn/fzf.vim'

    " work with git
    Plug 'tpope/vim-fugitive'
    Plug 'airblade/vim-gitgutter'
    " Plug 'mhinz/vim-signify' " replace gitgutter

    Plug 'will133/vim-dirdiff', {'on': 'DirDiff'}

    Plug 'nathanaelkane/vim-indent-guides'

    "------------------------------------------------------------------
    " Support more filetype specific feature
    "------------------------------------------------------------------
    Plug 'scrooloose/nerdcommenter'
    Plug 'SirVer/ultisnips'
    Plug 'honza/vim-snippets'

    Plug 'lotabout/vim-ultisnippet-private' " private snippets

    Plug 'w0rp/ale' " async version of Syntastic

    " in replace of paredit.vim
    Plug 'guns/vim-sexp', {'for': ['clojure', 'scheme', 'racket']}
    Plug 'tpope/vim-sexp-mappings-for-regular-people', {'for': ['clojure', 'scheme', 'racket']}

    Plug 'https://github.com/wlangstroth/vim-racket', {'for': 'racket'}

    Plug 'Rip-Rip/clang_complete', {'for': ['c', 'cpp']}

    " for python
    Plug 'bps/vim-textobj-python', {'for': 'python'}
    "Plug 'https://github.com/davidhalter/jedi-vim.git', {'for': 'python'}

    " for javascript
    Plug 'pangloss/vim-javascript'
    Plug 'mxw/vim-jsx', {'for': 'javascript.jsx'} " for react.js
    Plug 'othree/javascript-libraries-syntax.vim', {'for': 'javascript'}
    Plug 'mattn/emmet-vim', {'for': ['html', 'xml', 'css', 'nhtml', 'javascript', 'javascript.jsx', 'typescript']}

    " for clojure
    Plug 'guns/vim-clojure-static', {'for': 'clojure'}
    Plug 'tpope/vim-fireplace', {'for': 'clojure'}
    Plug 'guns/vim-clojure-highlight', {'for': 'clojure'}

    " for rust
    Plug 'rust-lang/rust.vim', {'for': 'rust'}

    " for markdown
    Plug 'plasticboy/vim-markdown', {'for': 'markdown'}
    Plug 'dkarter/bullets.vim', {'for': ['markdown', 'text', 'gitcommit']}

    " for typescript
    Plug 'HerringtonDarkholme/yats.vim', {'for': 'typescript'}
    Plug 'mhartington/nvim-typescript', {'for': 'typescript'}

    "------------------------------------------------------------------
    " Completion Framework
    "------------------------------------------------------------------
    if has('nvim')
        Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    else
        Plug 'Shougo/deoplete.nvim'
        Plug 'roxma/nvim-yarp'
        Plug 'roxma/vim-hug-neovim-rpc'
    endif

    let g:deoplete#enable_at_startup = 1
    Plug 'autozimu/LanguageClient-neovim', {
        \ 'branch': 'next',
        \ 'do': 'bash install.sh',
        \ }

    "------------------------------------------------------------------
    " Others
    "------------------------------------------------------------------
    Plug 'christoomey/vim-tmux-navigator'
    Plug 'mattn/calendar-vim'
    Plug 'lotabout/ywvim' " Chinese input method

    call plug#end()
elseif package_manager == "pathogen"
    execute pathogen#infect()
endif

"===============================================================================
" settings for bundle plugins

"----------------------------------------------------------------------
" Colors and Fonts

" Enable syntax highlighting
syntax enable

" Colorscheme
if has("gui_running")
    set background=dark
    colorscheme solarized
    set guifont=Fira\ Code:h16,Dejavu\ Sans\ Mono\ for\ Powerline:h16,Dejavu\ Sans\ Mono:h16
elseif &t_Co == 256
    set background=dark
    colorscheme solarized
else
    colorscheme desert
    if &term == "linux"
        colorscheme desert
    endif
endif

" Set extra options when running in GUI mode
if has("gui_running")
    "set guioptions-=m " remove menubar
    set guioptions-=T " remove toolbar
    set guioptions-=r " remove right-hand scroll bar
    set guioptions-=l " remove left-hand scroll bar
    set guioptions+=e
    set t_Co=256
    set guitablabel=%M\ %t
endif

"----------------------------------------------------------------------
" supertab

if exists('g:plugs["supertab"]')
    let g:SuperTabLongestEnhanced = 1
    let g:SuperTabDefaultCompletionType = "context"
    let g:SuperTabCrMapping = 1
endif

"----------------------------------------------------------------------
" vim-easy-align
if exists('g:plugs["vim-easy-align"]')
    xmap ga <Plug>(EasyAlign)
endif

"----------------------------------------------------------------------
" easymotion

if exists('g:plugs["vim-easymotion"]')
    let g:EasyMotion_do_mapping = 0 " Disable default mappings
    let g:EasyMotion_enter_jump_first = 1

    " Turn on case insensitive feature
    "let g:EasyMotion_smartcase = 1

    nmap f <Plug>(easymotion-s)
    vmap f <Plug>(easymotion-s)
    nmap F <Plug>(easymotion-F)
    vmap F <Plug>(easymotion-F)
    nmap <Leader>l <Plug>(easymotion-bd-jk)
    vmap <Leader>l <Plug>(easymotion-bd-jk)
    nmap <Space>. <Plug>(easymotion-repeat)
endif

"----------------------------------------------------------------------
" slimux

if exists('g:plugs["slimux"]')
    let g:slimux_select_from_current_window = 1
    map <Leader>s :SlimuxREPLSendLine<CR>
    vmap <Leader>s :SlimuxREPLSendSelection<CR>

    let g:slimux_scheme_keybindings=1
    let g:slimux_scheme_leader=';'
    let g:slimux_racket_keybindings=1
    let g:slimux_racket_leader=';'
    let g:slimux_racket_xrepl=1
    let g:slimux_clojure_keybindings=1
    let g:slimux_clojure_leader=';'
    let g:slimux_clojure_xrepl=1
    let g:slimux_python_use_ipython=1
endif

"----------------------------------------------------------------------
" NerdTree
if exists('g:plugs["nerdtree"]')
    nmap <silent> <leader>ne :NERDTreeToggle<cr>
    nmap <silent> <leader>nf :NERDTreeFind<cr>
endif

"----------------------------------------------------------------------
" Tagbar

if exists('g:plugs["tagbar"]')

    " nmap <silent> <leader>tl :TlistToggle<cr>
    nmap <silent> <leader>tl :TagbarToggle<cr>
    nmap <silent> <F8> :call  ToggleNERDTreeAndTagbar()<cr>

    function! ToggleNERDTreeAndTagbar()
        let w:jumpbacktohere = 1

        " Detect which plugins are open
        if exists('t:NERDTreeBufName')
            let nerdtree_open = bufwinnr(t:NERDTreeBufName) != -1
        else
            let nerdtree_open = 0
        endif
        let tagbar_open = bufwinnr('__Tagbar__') != -1

        " Perform the appropriate action
        if nerdtree_open && tagbar_open
            NERDTreeClose
            TagbarClose
        elseif nerdtree_open
            TagbarOpen
        elseif tagbar_open
            NERDTree
        else
            NERDTree
            TagbarOpen
        endif

        " Jump back to the original window
        for window in range(1, winnr('$'))
            execute window . 'wincmd w'
            if exists('w:jumpbacktohere')
                unlet w:jumpbacktohere
                break
            endif
        endfor
    endfunction
endif


"---------------------------------------------------------------------
" LargeFile

if exists("g:plugs['LargeFile']")
    let g:LargeFile = 10
endif

"---------------------------------------------------------------------
" fakeclip
if exists("g:plugs['vim-fakeclip']")
    let g:fakeclip_terminal_multiplexer_type = "tmux"
endif

"---------------------------------------------------------------------
" UltiSnips

if exists("g:plugs['ultisnips']")
    let g:UltiSnipsSnippetsDir = $VIMHOME . "plugged/vim-ultisnippet-private/UltiSnips"
    " load UltiSnips lazily
    augroup load_ultisnip
        autocmd!
        autocmd InsertEnter * call plug#load('ultisnips')
                    \| autocmd! load_ultisnip
    augroup END
endif

"---------------------------------------------------------------------
" fzf.vim

" change keybinding for AG
if executable('fzf') && exists('g:plugs["fzf.vim"]')
    let $FZF_DEFAULT_OPTS = '--bind ctrl-f:toggle'
    " replace Ctrl-p
    nmap <C-p> :Files<CR>

    " Customized binding for AG
    nnoremap <leader>/ :Ag<CR>

    " Replace Bufexplore
    nmap <C-e> :Buffers<CR>

    " select mapping
    nmap <leader><tab> <plug>(fzf-maps-n)
    xmap <leader><tab> <plug>(fzf-maps-x)
    omap <leader><tab> <plug>(fzf-maps-o)
endif

"---------------------------------------------------------------------
" skim.vim
if exists('g:plugs["skim.vim"]')
    let $SKIM_DEFAULT_COMMAND = '(git ls-files -c -o --exclude-standard || rg -l "" || ag -l -g "" || find . -type f)'
    let $SKIM_DEFAULT_OPTS = '--bind ctrl-f:toggle'
    " replace Ctrl-p
    nmap <C-p> :Files<CR>

    command! -bang -nargs=* Ag call fzf#vim#ag_interactive(<q-args>, fzf#vim#with_preview('right:50%:hidden', 'alt-h'))
    command! -bang -nargs=* Rg call fzf#vim#rg_interactive(<q-args>, fzf#vim#with_preview('right:50%:hidden', 'alt-h'))

    " Customized binding for Rg
    nnoremap <leader>/ :Rg<CR>

    nnoremap <leader>i :BTags<CR>
    nnoremap <leader>I :Tags<CR>

    " Replace Bufexplore
    nmap <C-e> :Buffers<CR>
endif

"---------------------------------------------------------------------
" Gundo
if exists('g:plugs["gundo.vim"]')
    nnoremap <F5> :GundoToggle<CR>
endif

"---------------------------------------------------------------------
" DelimitMate

if exists('g:plugs["delimitMate"]')
    " not used
    au FileType racket,clojure let b:delimitMate_quotes = "\""
endif

"---------------------------------------------------------------------
" Personal wiki
let g:wiki_directory = $HOME . '/Dropbox/wiki'

function! CreateMappingForPersonalWiki()
    execute("nmap <buffer> <C-p> :Files ".g:wiki_directory."<CR>")
    execute("nmap <buffer> <leader>/ :Rg ".g:wiki_directory."<CR>")
    execute("nmap <buffer> <C-n> :e ".g:wiki_directory."/")
endfunction

function! BindForWikiFiles()
    if expand('%:p') =~ '^'. g:wiki_directory
        call CreateMappingForPersonalWiki()
    endif
endfunction

au FileType markdown call BindForWikiFiles()
au FileType startify call CreateMappingForPersonalWiki()

"---------------------------------------------------------------------
" calendar-vim

if exists('g:plugs["calendar-vim"]')
    let g:calendar_filetype = 'markdown'
    let g:calendar_diary= g:wiki_directory . '/diary'

endif

"---------------------------------------------------------------------
" vim-airline
if exists('g:plugs["vim-airline"]')
    if has("gui_running")
        let g:airline_theme='solarized'
    else
        "let g:airline_theme='wombat'
        let g:airline_theme='solarized'
    endif
    let g:airline_powerline_fonts = 1
    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#tabline#show_buffers = 0
    let g:airline#extensions#tabline#show_splits = 0
    let g:airline#extensions#tabline#show_tab_nr = 0
    let g:airline#extensions#tabline#tab_min_count = 2
endif

"---------------------------------------------------------------------
" vim-tmux-navigator
if exists('g:plugs["vim-tmux-navigator"]')
    let g:tmux_navigator_no_mappings = 1

    nnoremap <silent> <C-h> :TmuxNavigateLeft<cr>
    nnoremap <silent> <C-j> :TmuxNavigateDown<cr>
    nnoremap <silent> <C-k> :TmuxNavigateUp<cr>
    nnoremap <silent> <C-l> :TmuxNavigateRight<cr>
    " originally binded to C-l, now change to C-d
    nnoremap <silent> <C-d> :<C-u>nohlsearch<CR><C-l>
    nnoremap <silent> <C-\> :TmuxNavigatePrevious<cr>
endif

"---------------------------------------------------------------------
" vim-choosewin
if exists('g:plugs["vim-choosewin"]')
    nmap - <Plug>(choosewin)
    let g:choosewin_blink_on_land  = 0 " don't blink at land
    let g:choosewin_overlay_enable = 1
endif

if exists('g:plugs["vim-hardtime"]')
    nnoremap <silent> <leader>h :HardTimeToggle<CR>
endif

"----------------------------------------------------------------------
" indent-guides
if exists('g:plugs["vim-indent-guides"]')
    let g:indent_guides_default_mapping = 0
    let g:indent_guides_start_level = 2
    let g:indent_guides_guide_size = 1
endif

"----------------------------------------------------------------------
" ale/syntastic
if exists('g:plugs["ale"]')
    nmap <silent> [e <Plug>(ale_previous_wrap)
    nmap <silent> ]e <Plug>(ale_next_wrap)

    let g:syntastic_mode_map = {
                \ "mode": "active",
                \ "passive_filetypes": ["java", "racket"] }
endif


"----------------------------------------------------------------------
" neoformat

if exists('g:plugs["neoformat"]')
  nmap <silent> <leader>f :Neoformat<CR>
endif

"----------------------------------------------------------------------
" LanguageClient-neovim

if exists('g:plugs["LanguageClient-neovim"]')
    " Required for operations modifying multiple buffers like rename.
    set hidden

    " rustup component add rls-preview rust-analysis rust-src
    " pip install pyls
    " npm install -g typescript-language-server

    let g:LanguageClient_serverCommands = {
        \ 'rust': ['rustup', 'run', 'stable', 'rls'],
        \ 'python': ['pyls'],
        \ }

    let g:LanguageClient_changeThrottle = 0.5

    function! LanguageClientInit()
        nnoremap <buffer><silent> K :call LanguageClient_textDocument_hover()<CR>
        nnoremap <buffer><silent> gd :call LanguageClient_textDocument_definition()<CR>
        nnoremap <buffer><silent> <F2> :call LanguageClient_textDocument_rename()<CR>
        setlocal formatexpr=LanguageClient_textDocument_rangeFormatting()
    endfunction

    au Filetype rust,python call LanguageClientInit()
endif

"----------------------------------------------------------------------
" jedi-vim

if exists('g:plugs["jedi-vim"]')
    " use deoplete-jedi for completion, so disable completion of jedi-vim
    let g:jedi#completions_enabled = 0
    let g:jedi#goto_command = "<C-]>"
endif

"----------------------------------------------------------------------
" vim-gitgutter

if exists('g:plugs["vim-gitgutter"]')
    let g:gitgutter_map_keys = 0
    nmap <silent> ]g :GitGutterNextHunk<CR>
    nmap <silent> [g :GitGutterPrevHunk<CR>
endif

"----------------------------------------------------------------------
" ywvim: input method for chinese
if exists('g:plugs["ywvim"]')
    let g:ywvim_ims=[
                \['wb', '五笔', 'wubi.ywvim'],
                \['py', '拼音', 'pinyin.ywvim'],
                \]

    let g:ywvim_py = { 'helpim':'wb', 'gb':0 }

    let g:ywvim_zhpunc = 1
    let g:ywvim_listmax = 10
    let g:ywvim_esc_autoff = 0
    let g:ywvim_autoinput = 0
    let g:ywvim_circlecandidates = 1
    let g:ywvim_helpim_on = 1          " 五笔反查
    let g:ywvim_matchexact = 0
    let g:ywvim_chinesecode = 1
    let g:ywvim_gb = 0
    let g:ywvim_preconv = 'g2b'
    let g:ywvim_conv = ''
    let g:ywvim_lockb = 1
    let g:ywvim_theme = 'dark'
endif

"===============================================================================
" self-added plugins && settigns

"---------------------------------------------------------------------
" i_emacs
let g:i_emacs_loaded = 1

"===============================================================================
" settings for filetypes

"----------------------------------------------------------------------
" C

autocmd FileType c,cpp setlocal colorcolumn=80

"----------------------------------------------------------------------
" python
let g:enable_my_python_config = 1

"----------------------------------------------------------------------
" markdown

if exists('g:plugs["vim-markdown"]')
    let g:vim_markdown_folding_disabled = 1
    let g:vim_markdown_frontmatter=1
    let g:vim_markdown_follow_anchor = 1
    let g:vim_markdown_conceal = 0
    let g:tex_conceal = ""
    let g:vim_markdown_math = 1
    let g:vim_markdown_frontmatter = 1
endif

"----------------------------------------------------------------------
" bullets
if exists('g:plugs["bullets.vim"]')
    let g:bullets_set_mappings = 0

    au FileType markdown,text,gitcommit nmap <silent> <C-Space> :ToggleCheckbox<CR>
    au FileType markdown,text,gitcommit nmap <silent> <C-@> :ToggleCheckbox<CR>
endif

"----------------------------------------------------------------------
" javascript

if exists('javascript-libraries-syntax.vim')
    let g:used_javascript_libs = 'underscore,jquery,angularjs,angularui,react'
    let g:jsx_ext_required = 0 " Allow JSX in normal JS files
endif

" Syntastic
let g:syntastic_javascript_checkers = ['eslint']

au BufNewFile,BufRead *.js,*.jsx,*.ts,*.tsx,*.html,*.css
    \ set tabstop=2 |
    \ set softtabstop=2 |
    \ set shiftwidth=2 |
    \ set smarttab

"===============================================================================
" client specified settings

if has('nvim')
    "--------------------------------------------------
    " neovim specified settings

    "- - - - - - - - - - - - - - - - - - - - - - - - -
    " mappings

    " Fast editing or sourcing vimrc file
    nmap <silent> <leader>ee :tabnew<cr>:edit ~/.config/nvim/init.vim<cr>

    tnoremap <C-h> <C-\><C-n>:TmuxNavigateLeft<cr>
    tnoremap <C-j> <C-\><C-n>:TmuxNavigateDown<cr>
    tnoremap <C-k> <C-\><C-n>:TmuxNavigateUp<cr>
    tnoremap <C-l> <C-\><C-n>:TmuxNavigateRight<cr>
    tnoremap <C-\> <C-\><C-n>:TmuxNavigatePrevious<cr>

    if exists('g:plugs["deoplete.nvim"]')
        let g:deoplete#enable_at_startup = 1
    endif

    "- - - - - - - - - - - - - - - - - - - - - - - - -
    " Custom yank ring, utilize numbered registers for yank too.
    function! YankRing(event)
        if (len(a:event.regcontents) == 1 && len(a:event.regcontents[0]) <= 1)
                    \ || a:event.operator == 'd'
            return
        end
        if a:event.regname == ''
            " shfit the numbered registers
            for reg in range(9, 2, -1)
                call setreg(string(reg), getreg(string(reg-1)))
            endfor
            call setreg(1, a:event.regcontents)
        endif
    endfunction

    " Register the TextYankPost event
    au! TextYankPost * call YankRing(copy(v:event))
else
    "--------------------------------------------------
    " vim specified settings

    " use blowfish as default crypt method
    set cryptmethod=blowfish

    " Fast editing or sourcing vimrc file
    nmap <silent> <leader>ee :tabnew<cr>:edit ~/.vimrc<cr>
endif


if has("gui_macvim")
    set macligatures " Enable ligatures for font 'Fira Code'

    " Need this if python is installed via homebrew
    " check this https://github.com/macvim-dev/macvim/issues/562
    if has('python3')
        command! -nargs=1 Py py3 <args>
        set pythonthreedll=/usr/local/Frameworks/Python.framework/Versions/3.6/Python
        set pythonthreehome=/usr/local/Frameworks/Python.framework/Versions/3.6
    else
        command! -nargs=1 Py py <args>
        set pythondll=/usr/local/Frameworks/Python.framework/Versions/2.7/Python
        set pythonhome=/usr/local/Frameworks/Python.framework/Versions/2.7
    endif
endif
