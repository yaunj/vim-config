" Function to display filename of current buffer with git branch name if in a
" directory tracked by git.
function yaunj_statusline#Filename()
    let filename = expand('%') !=# '' ? expand('%:~:.') : '[No Name]'
    let branch = exists("*gitbranch#name") ? gitbranch#name() : yaunj_statusline#GitBranch()
    let branch = branch !=# '' ? ' (' . branch . ')' : ''
    return filename . branch
endfunction

function yaunj_statusline#GitBranch()
    return system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
endfunction

set statusline=
set statusline+=%1*            " set colors to User1 for the first part
set statusline+=%Y%M%R%W       " filetype and flags
set statusline+=%*             " reset colors
set statusline+=\ %<%{yaunj_statusline#Filename()}\  " start truncation here and add filename
set statusline+=%=             " move to right hand side
set statusline+=[%{&fenc},%{&fileformat}]\  " file encoding + format
set statusline+=(%l,%v         " cursor position with byte optional offset
set statusline+=%{col('.')>virtcol('.')?'['.col('.').']':''}
set statusline+=)\ 
set statusline+=%P             " percentage into file
