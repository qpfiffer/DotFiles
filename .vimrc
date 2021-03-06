syntax on
filetype indent plugin on
set number
"set background=dark

" Haskell stuff

" Sensible tabs
set tabstop=4
set expandtab
set shiftwidth=4
set softtabstop=4
set modeline

" Colors
set t_Co=256
colorscheme jellybeans

" Any lines over 80 chars are red
"highlight OverLength ctermbg=red ctermfg=white guibg=#592929
"match OverLength /\%78v.\+/
set nowrap

" Whitespace
set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
set list

" Autocomplete stuff.
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete tabstop=4 expandtab shiftwidth=4 softtabstop=4
autocmd FileType c set tabstop=4 expandtab shiftwidth=4 softtabstop=4 omnifunc=ccomplete#Complete
autocmd FileType rs set cindent tabstop=4 expandtab shiftwidth=4 softtabstop=4 omnifunc=ccomplete#Complete
set completeopt=menu,longest
set pumheight=8
highlight PmenuSel ctermfg=black ctermbg=white gui=bold
"let g:acp_completeoptPreview=1
autocmd Filetype markdown setlocal wrap linebreak showbreak=> textwidth=80
autocmd Filetype rst setlocal wrap linebreak showbreak=> textwidth=80
autocmd BufRead,BufNewFile *.jinja2 set filetype=htmldjango
autocmd BufRead,BufNewFile *.go set filetype=go noet ts=4 sw=4 sts=4
autocmd BufRead,BufNewFile *.coffee set filetype=coffee noet ts=4 sw=4 sts=4 autoindent
autocmd BufRead,BufNewFile *.rb set filetype=ruby tabstop=2 expandtab shiftwidth=2 softtabstop=2
autocmd BufRead,BufNewFile *.rs set filetype=rust ts=4 sw=4
autocmd BufRead,BufNewFile *.jl set filetype=julia ts=4 sw=4
"autocmd BufRead,BufNewFile *.js set filetype=javascript ts=2 sw=2 expandtab softtabstop=2 autoread
"autocmd bufwritepost *.js silent !standard % --fix --format &> /dev/null
autocmd BufRead,BufNewFile *.hs set filetype=haskell ts=4 sw=4
autocmd BufRead,BufNewFile *.cr set filetype=ruby tabstop=2 expandtab shiftwidth=2 softtabstop=2
autocmd BufRead,BufNewFile scratch set autoindent
set ruler
set backspace=indent,eol,start
let g:PyFlakeOnWrite = 1
let g:PyFlakeSigns = 1
set wildmode=longest:full,full
set pastetoggle=<F2>
set timeoutlen=1000 ttimeoutlen=0
" Flake8 stuff:
"let g:flake8_show_in_file = 1
"autocmd BufWritePost *.py call flake8#Flake8()
