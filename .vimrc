set tabstop=4
set softtabstop=4
set shiftwidth=4
set noexpandtab

set autoindent
set smartindent

" switch cursor between visual and insert mode
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"


syntax on

inoremap { {}<left>
inoremap ( ()<left>
inoremap [ []<left>
inoremap " ""<left>
inoremap ' ''<left>

set laststatus=2

set statusline=
set statusline+=\ %F                                 
