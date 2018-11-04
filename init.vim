" Plug for plugins
call plug#begin('~/.vim/plugged')

Plug 'flazz/vim-colorschemes' " All the colorschemes
Plug 'tpope/vim-fugitive'     " Git Commands
Plug 'fatih/vim-go'           " Lets do go development
Plug 'benekastah/neomake'     " Nevoim specific plugins
Plug 'tpope/vim-unimpaired'   " Pairs of handy bracket mappings
Plug 'tpope/vim-commentary'   " Make commenting easier
Plug 'tpope/vim-vinegar'      " make netrw way better

call plug#end()

syntax on " Syntax highlighting FTW
set background=dark " Set background to dark for base16
colorscheme tomorrow-night " Set colorscheme to hybrid
set directory=/tmp " Move swp to a standard location
:let mapleader = ',' " Remap the leader key
autocmd! BufWritePost * Neomake " Run neomake, it's like syntastic
" Yank to system clipboard
vnoremap <leader>y "*y
nnoremap <leader>y "*y

" Setting Spacing and Indent (plus line no)
set nu
set tabstop=2 shiftwidth=2 expandtab
set ts=2
set nowrap

" Set 256 colors
set t_Co=256
set guifont=Inconsolata:h16

" Hidden characters
set listchars=tab:\ \ ,trail:█
set list

" Go Declaration
au FileType go nmap gd <Plug>(go-def)
let g:go_fmt_command = "goimports"
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_interfaces = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1

" Turn on go-implements
au FileType go nmap <Leader>i <Plug>(go-implements)

" Open test file in new window
au FileType go nmap <Leader>a :vsp<CR>:GoAlternate<CR>

" Make YAML Great Again
autocmd FileType yaml setlocal indentexpr=

" Run neomake on buffer write
call neomake#configure#automake('w')

" MULTIPURPOSE TAB KEY
" Indent if we're at the beginning of a line. Else, do completion.
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction
inoremap <tab> <c-r>=InsertTabWrapper()<cr>
inoremap <s-tab> <c-n>

let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
