if executable('rg')
    set grepprg=rg\ --vimgrep
    let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
    let g:ctrlp_use_caching = 0
endif
