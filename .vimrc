syntax on
filetype indent plugin on
set number
"set background=dark

" Haskell stuff
au Bufenter *.hs compiler ghc
let g:haddock_browser = "/usr/bin/firefox-nightly"

" Sensible tabs
set tabstop=4
set expandtab
set shiftwidth=4
set softtabstop=4

" Colors
set t_Co=256
colorscheme jellybeans

" Any lines over 80 chars are red
highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%78v.\+/
set nowrap

" Whitespace
set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
set list

" Autocomplete stuff.
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete tabstop=4 expandtab shiftwidth=4 softtabstop=4
autocmd FileType c set tabstop=4 expandtab shiftwidth=4 softtabstop=4 omnifunc=ccomplete#Complete
set completeopt=menu,longest,preview
set pumheight=8
highlight PmenuSel ctermfg=black ctermbg=white gui=bold
let g:acp_completeoptPreview=1
