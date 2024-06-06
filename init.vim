" Plug for plugins
call plug#begin('~/.vim/plugged')

Plug 'dense-analysis/ale'      " Linting
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' } " Autocomplete
Plug 'cespare/vim-toml'
Plug 'airblade/vim-gitgutter'
Plug 'wfxr/protobuf.vim'
Plug 'hashivim/vim-terraform'
Plug 'rust-lang/rust.vim'

call plug#end()

" Go Declaration
let g:go_fmt_command = "goimports"
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_interfaces = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_function_parameters = 1
let g:go_highlight_function_calls = 1
let g:go_auto_type_info = 0

" Linting
let g:ale_linters = {
\   'go': ['go build', 'golangci-lint'],
\   'javascript': ['eslint', 'flow-language-server'],
\}
let g:ale_go_golangci_lint_package = 1
let g:ale_go_golangci_lint_options = '--enable bodyclose --enable revive --enable gosec --enable unparam --enable scopelint --enable godox --enable testpackage --disable unused --disable deadcode'

" Fixing
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\}

" Unbreak YAML indents
autocmd FileType yaml setlocal indentexpr=
let g:ale_yaml_yamllint_options = '-c ~/.config/nvim/.yamllint'
