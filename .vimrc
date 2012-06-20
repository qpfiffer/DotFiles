syntax on
filetype indent plugin on
set number
set background=dark

set tabstop=4
set expandtab
set shiftwidth=4
set softtabstop=4

set t_Co=16
let g:solarized_termcolors=16
colorscheme solarized

autocmd FileType python setlocal omnifunc=pythoncomplete#Complete tabstop=4 expandtab shiftwidth=4 softtabstop=4
autocmd FileType c set tabstop=4 expandtab shiftwidth=4 softtabstop=4 omnifunc=ccomplete#Complete
