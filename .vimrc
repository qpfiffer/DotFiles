syntax on
filetype indent plugin on
set number
set background=dark

set tabstop=4
set expandtab
set shiftwidth=4
set softtabstop=4

set t_Co=256
colorscheme jellybeans

set textwidth=75
set nowrap
set linebreak

" vertical/horizontal column indicator

let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplMapWindowNavArrows = 1
let g:miniBufExplMapCTabSwitchBufs = 1
let g:miniBufExplModSelTarget = 1 

" Autocomplete stuff.
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete tabstop=4 expandtab shiftwidth=4 softtabstop=4
autocmd FileType c set tabstop=4 expandtab shiftwidth=4 softtabstop=4 omnifunc=ccomplete#Complete
set completeopt=menu,longest,preview
set pumheight=8
highlight PmenuSel ctermfg=black ctermbg=white gui=bold
let g:acp_completeoptPreview=1
