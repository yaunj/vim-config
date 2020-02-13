" This file is sourced after the corresponding ftplugin is loaded
" https://vimways.org/2018/from-vimrc-to-vim/
setlocal ts=4

nmap <leader>r <Plug>(go-run)
nmap <leader>t <Plug>(go-test)
nmap <leader>a <Plug>(go-alternate-edit)

let g:go_fmt_command = "goimports"
