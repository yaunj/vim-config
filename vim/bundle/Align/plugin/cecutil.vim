510
" cecutil.vim : save/restore window position
"               save/restore mark position
"               save/restore selected user maps
"  Author:	Charles E. Campbell, Jr.
"  Version:	18b	ASTRO-ONLY
"  Date:	Aug 27, 2008
"
"  Saving Restoring Destroying Marks: {{{1
"       call SaveMark(markname)       let savemark= SaveMark(markname)
"       call RestoreMark(markname)    call RestoreMark(savemark)
"       call DestroyMark(markname)
"       commands: SM RM DM
"
"  Saving Restoring Destroying Window Position: {{{1
"       call SaveWinPosn()        let winposn= SaveWinPosn()
"       call RestoreWinPosn()     call RestoreWinPosn(winposn)
"		\swp : save current window/buffer's position
"		\rwp : restore current window/buffer's previous position
"       commands: SWP RWP
"
"  Saving And Restoring User Maps: {{{1
"       call SaveUserMaps(mapmode,maplead,mapchx,suffix)
"       call RestoreUserMaps(suffix)
"
" GetLatestVimScripts: 1066 1 :AutoInstall: cecutil.vim
"
" You believe that God is one. You do well. The demons also {{{1
" believe, and shudder. But do you want to know, vain man, that
" faith apart from works is dead?  (James 2:19,20 WEB)

" ---------------------------------------------------------------------
" Load Once: {{{1
if &cp || exists("g:loaded_cecutil")
 finish
endif
let g:loaded_cecutil = "v18b"
let s:keepcpo        = &cpo
set cpo&vim
"DechoTabOn

" =======================
"  Public Interface: {{{1
" =======================

" ---------------------------------------------------------------------
"  Map Interface: {{{2
if !hasmapto('<Plug>SaveWinPosn')
 map <unique> <Leader>swp <Plug>SaveWinPosn
endif
if !hasmapto('<Plug>RestoreWinPosn')
 map <unique> <Leader>rwp <Plug>RestoreWinPosn
endif
nmap <silent> <Plug>SaveWinPosn		:call SaveWinPosn()<CR>
nmap <silent> <Plug>RestoreWinPosn	:call RestoreWinPosn()<CR>

" ---------------------------------------------------------------------
" Command Interface: {{{2
com! -bar -nargs=0 SWP	call SaveWinPosn()
com! -bar -nargs=0 RWP	call RestoreWinPosn()
com! -bar -nargs=1 SM	call SaveMark(<q-args>)
com! -bar -nargs=1 RM	call RestoreMark(<q-args>)
com! -bar -nargs=1 DM	call DestroyMark(<q-args>)

if v:version < 630
 let s:modifier= "sil "
else
 let s:modifier= "sil keepj "
endif

" ===============
" Functions: {{{1
" ===============

" ---------------------------------------------------------------------
" SaveWinPosn: {{{2
"    let winposn= SaveWinPosn()  will save window position in winposn variable
"    call SaveWinPosn()          will save window position in b:cecutil_winposn{b:cecutil_iwinposn}
"    let winposn= SaveWinPosn(0) will *only* save window position in winposn variable (no stacking done)
fun! SaveWinPosn(...)
"  call Dfunc("SaveWinPosn() a:0=".a:0)
  if line(".") == 1 && getline(1) == ""
"   call Dfunc("SaveWinPosn : empty buffer")
   return ""
  endif
  let so_keep   = &l:so
  let siso_keep = &siso
  let ss_keep   = &l:ss
  setlocal so=0 siso=0 ss=0

  let swline    = line(".")
  let swcol     = col(".")
  let swwline   = winline() - 1
  let swwcol    = virtcol(".") - wincol()
  let savedposn = "call GoWinbufnr(".winbufnr(0).")|silent ".swline
  let savedposn = savedposn."|".s:modifier."norm! 0z\<cr>"
  if swwline > 0
   let savedposn= savedposn.":".s:modifier."norm! ".swwline."\<c-y>\<cr>"
  endif
  if swwcol > 0
   let savedposn= savedposn.":".s:modifier."norm! 0".swwcol."zl\<cr>"
  endif
  let savedposn = savedposn.":".s:modifier."call cursor(".swline.",".swcol.")\<cr>"

  " save window position in
  " b:cecutil_winposn_{iwinposn} (stack)
  " only when SaveWinPosn() is used
  if a:0 == 0
   if !exists("b:cecutil_iwinposn")
   	let b:cecutil_iwinposn= 1
   else
   	let b:cecutil_iwinposn= b:cecutil_iwinposn + 1
   endif
"   call Decho("saving posn to SWP stack")
   let b:cecutil_winposn{b:cecutil_iwinposn}= savedposn
  endif

  let &l:so = so_keep
  let &siso = siso_keep
  let &l:ss = ss_keep

"  if exists("b:cecutil_iwinposn")	 " Decho
"   call Decho("b:cecutil_winpos{".b:cecutil_iwinposn."}[".b:cecutil_winposn{b:cecutil_iwinposn}."]")
"  else                      " Decho
"   call Decho("b:cecutil_iwinposn doesn't exist")
"  endif                     " Decho
"  call Dret("SaveWinPosn [".savedposn."]")
  return savedposn
endfun

" ---------------------------------------------------------------------
" RestoreWinPosn: {{{2
"      call RestoreWinPosn()
"      call RestoreWinPosn(winposn)
fun! RestoreWinPosn(...)
"  call Dfunc("RestoreWinPosn() a:0=".a:0)
"  call Decho("getline(1)<".getline(1).">")
"  call Decho("line(.)=".line("."))
  if line(".") == 1 && getline(1) == ""
"   call Dfunc("RestoreWinPosn : empty buffer")
   return ""
  endif
  let so_keep   = &l:so
  let siso_keep = &l:siso
  let ss_keep   = &l:ss
  setlocal so=0 siso=0 ss=0

  if a:0 == 0 || a:1 == ""
   " use saved window position in b:cecutil_winposn{b:cecutil_iwinposn} if it exists
   if exists("b:cecutil_iwinposn") && exists("b:cecutil_winposn{b:cecutil_iwinposn}")
"   	call Decho("using stack b:cecutil_winposn{".b:cecutil_iwinposn."}<".b:cecutil_winposn{b:cecutil_iwinposn}.">")
	try
     exe "silent! ".b:cecutil_winposn{b:cecutil_iwinposn}
	catch /^Vim\%((\a\+)\)\=:E749/
	 " ignore empty buffer error messages
	endtry
    " normally drop top-of-stack by one
    " but while new top-of-stack doesn't exist
    " drop top-of-stack index by one again
	if b:cecutil_iwinposn >= 1
	 unlet b:cecutil_winposn{b:cecutil_iwinposn}
	 let b:cecutil_iwinposn= b:cecutil_iwinposn - 1
	 while b:cecutil_iwinposn >= 1 && !exists("b:cecutil_winposn{b:cecutil_iwinposn}")
	  let b:cecutil_iwinposn= b:cecutil_iwinposn - 1
	 endwhile
	 if b:cecutil_iwinposn < 1
	  unlet b:cecutil_iwinposn
	 endif
	endif
   else
   	echohl WarningMsg
	echomsg "***warning*** need to SaveWinPosn first!"
	echohl None
   endif

  else	 " handle input argument
"   call Decho("using input a:1<".a:1.">")
   " use window position passed to this function
   exe "silent ".a:1
   " remove a:1 pattern from b:cecutil_winposn{b:cecutil_iwinposn} stack
   if exists("b:cecutil_iwinposn")
    let jwinposn= b:cecutil_iwinposn
    while jwinposn >= 1                     " search for a:1 in iwinposn..1
        if exists("b:cecutil_winposn{jwinposn}")    " if it exists
         if a:1 == b:cecutil_winposn{jwinposn}      " and the pattern matches
       unlet b:cecutil_winposn{jwinposn}            " unlet it
       if jwinposn == b:cecutil_iwinposn            " if at top-of-stack
        let b:cecutil_iwinposn= b:cecutil_iwinposn - 1      " drop stacktop by one
       endif
      endif
     endif
     let jwinposn= jwinposn - 1
    endwhile
   endif
  endif

  " Seems to be something odd: vertical motions after RWP
  " cause jump to first column.  The following fixes that.
  " Note: was using wincol()>1, but with signs, a cursor
  " at column 1 yields wincol()==3.  Beeping ensued.
  if virtcol('.') > 1
   silent norm! hl
  elseif virtcol(".") < virtcol("$")
   silent norm! lh
  endif

  let &l:so   = so_keep
  let &l:siso = siso_keep
  let &l:ss   = ss_keep

"  call Dret("RestoreWinPosn")
endfun

" ---------------------------------------------------------------------
" GoWinbufnr: go to window holding given buffer (by number) {{{2
"   Prefers current window; if its buffer number doesn't match,
"   then will try from topleft to bottom right
fun! GoWinbufnr(bufnum)
"  call Dfunc("GoWinbufnr(".a:bufnum.")")
  if winbufnr(0) == a:bufnum
"   call Dret("GoWinbufnr : winbufnr(0)==a:bufnum")
   return
  endif
  winc t
  let first=1
  while winbufnr(0) != a:bufnum && (first || winnr() != 1)
  	winc w
	let first= 0
   endwhile
"  call Dret("GoWinbufnr")
endfun

" ---------------------------------------------------------------------
" SaveMark: sets up a string saving a mark position. {{{2
"           For example, SaveMark("a")
"           Also sets up a global variable, g:savemark_{markname}
fun! SaveMark(markname)
"  call Dfunc("SaveMark(markname<".a:markname.">)")
  let markname= a:markname
  if strpart(markname,0,1) !~ '\a'
   let markname= strpart(markname,1,1)
  endif
"  call Decho("markname=".markname)

  let lzkeep  = &lz
  set lz

  if 1 <= line("'".markname) && line("'".markname) <= line("$")
   let winposn               = SaveWinPosn(0)
   exe s:modifier."norm! `".markname
   let savemark              = SaveWinPosn(0)
   let g:savemark_{markname} = savemark
   let savemark              = markname.savemark
   call RestoreWinPosn(winposn)
  else
   let g:savemark_{markname} = ""
   let savemark              = ""
  endif

  let &lz= lzkeep

"  call Dret("SaveMark : savemark<".savemark.">")
  return savemark
endfun

" ---------------------------------------------------------------------
" RestoreMark: {{{2
"   call RestoreMark("a")  -or- call RestoreMark(savemark)
fun! RestoreMark(markname)
"  call Dfunc("RestoreMark(markname<".a:markname.">)")

  if strlen(a:markname) <= 0
"   call Dret("RestoreMark : no such mark")
   return
  endif
  let markname= strpart(a:markname,0,1)
  if markname !~ '\a'
   " handles 'a -> a styles
   let markname= strpart(a:markname,1,1)
  endif
"  call Decho("markname=".markname." strlen(a:markname)=".strlen(a:markname))

  let lzkeep  = &lz
  set lz
  let winposn = SaveWinPosn(0)

  if strlen(a:markname) <= 2
   if exists("g:savemark_{markname}") && strlen(g:savemark_{markname}) != 0
	" use global variable g:savemark_{markname}
"	call Decho("use savemark list")
	call RestoreWinPosn(g:savemark_{markname})
	exe "norm! m".markname
   endif
  else
   " markname is a savemark command (string)
"	call Decho("use savemark command")
   let markcmd= strpart(a:markname,1)
   call RestoreWinPosn(markcmd)
   exe "norm! m".markname
  endif

  call RestoreWinPosn(winposn)
  let &lz       = lzkeep

"  call Dret("RestoreMark")
endfun

" ---------------------------------------------------------------------
" DestroyMark: {{{2
"   call DestroyMark("a")  -- destroys mark
fun! DestroyMark(markname)
"  call Dfunc("DestroyMark(markname<".a:markname.">)")

  " save options and set to standard values
  let reportkeep= &report
  let lzkeep    = &lz
  set lz report=10000

  let markname= strpart(a:markname,0,1)
  if markname !~ '\a'
   " handles 'a -> a styles
   let markname= strpart(a:markname,1,1)
  endif
"  call Decho("markname=".markname)

  let curmod  = &mod
  let winposn = SaveWinPosn(0)
  1
  let lineone = getline(".")
  exe "k".markname
  d
  put! =lineone
  let &mod    = curmod
  call RestoreWinPosn(winposn)

  " restore options to user settings
  let &report = reportkeep
  let &lz     = lzkeep

"  call Dret("DestroyMark")
endfun

" ---------------------------------------------------------------------
" QArgSplitter: to avoid \ processing by <f-args>, <q-args> is needed. {{{2
" However, <q-args> doesn't split at all, so this one returns a list
" with splits at all whitespace (only!), plus a leading length-of-list.
" The resulting list:  qarglist[0] corresponds to a:0
"                      qarglist[i] corresponds to a:{i}
fun! QArgSplitter(qarg)
"  call Dfunc("QArgSplitter(qarg<".a:qarg.">)")
  let qarglist    = split(a:qarg)
  let qarglistlen = len(qarglist)
  let qarglist    = insert(qarglist,qarglistlen)
"  call Dret("QArgSplitter ".string(qarglist))
  return qarglist
endfun

" ---------------------------------------------------------------------
" ListWinPosn: {{{2
"fun! ListWinPosn()                                                        " Decho 
"  if !exists("b:cecutil_iwinposn") || b:cecutil_iwinposn == 0             " Decho 
"   call Decho("nothing on SWP stack")                                     " Decho
"  else                                                                    " Decho
"   let jwinposn= b:cecutil_iwinposn                                       " Decho 
"   while jwinposn >= 1                                                    " Decho 
"    if exists("b:cecutil_winposn{jwinposn}")                              " Decho 
"     call Decho("winposn{".jwinposn."}<".b:cecutil_winposn{jwinposn}.">") " Decho 
"    else                                                                  " Decho 
"     call Decho("winposn{".jwinposn."} -- doesn't exist")                 " Decho 
"    endif                                                                 " Decho 
"    let jwinposn= jwinposn - 1                                            " Decho 
"   endwhile                                                               " Decho 
"  endif                                                                   " Decho
"endfun                                                                    " Decho 
"com! -nargs=0 LWP	call ListWinPosn()                                    " Decho 

" ---------------------------------------------------------------------
" SaveUserMaps: this function sets up a script-variable (s:restoremap) {{{2
"          which can be used to restore user maps later with
"          call RestoreUserMaps()
"
"          mapmode - see :help maparg for details (n v o i c l "")
"                    ex. "n" = Normal
"                    The letters "b" and "u" are optional prefixes;
"                    The "u" means that the map will also be unmapped
"                    The "b" means that the map has a <buffer> qualifier
"                    ex. "un"  = Normal + unmapping
"                    ex. "bn"  = Normal + <buffer>
"                    ex. "bun" = Normal + <buffer> + unmapping
"                    ex. "ubn" = Normal + <buffer> + unmapping
"          maplead - see mapchx
"          mapchx  - "<something>" handled as a single map item.
"                    ex. "<left>"
"                  - "string" a string of single letters which are actually
"                    multiple two-letter maps (using the maplead:
"                    maplead . each_character_in_string)
"                    ex. maplead="\" and mapchx="abc" saves user mappings for
"                        \a, \b, and \c
"                    Of course, if maplead is "", then for mapchx="abc",
"                    mappings for a, b, and c are saved.
"                  - :something  handled as a single map item, w/o the ":"
"                    ex.  mapchx= ":abc" will save a mapping for "abc"
"          suffix  - a string unique to your plugin
"                    ex.  suffix= "DrawIt"
fun! SaveUserMaps(mapmode,maplead,mapchx,suffix)
"  call Dfunc("SaveUserMaps(mapmode<".a:mapmode."> maplead<".a:maplead."> mapchx<".a:mapchx."> suffix<".a:suffix.">)")

  if !exists("s:restoremap_{a:suffix}")
   " initialize restoremap_suffix to null string
   let s:restoremap_{a:suffix}= ""
  endif

  " set up dounmap: if 1, then save and unmap  (a:mapmode leads with a "u")
  "                 if 0, save only
  let mapmode  = a:mapmode
  let dounmap  = 0
  let dobuffer = ""
  while mapmode =~ '^[bu]'
   if     mapmode =~ '^u'
    let dounmap= 1
    let mapmode= strpart(a:mapmode,1)
   elseif mapmode =~ '^b'
    let dobuffer= "<buffer> "
    let mapmode= strpart(a:mapmode,1)
   endif
  endwhile
"  call Decho("dounmap=".dounmap."  dobuffer<".dobuffer.">")
 
  " save single map :...something...
  if strpart(a:mapchx,0,1) == ':'
"   call Decho("save single map :...something...")
   let amap= strpart(a:mapchx,1)
   if amap == "|" || amap == "\<c-v>"
    let amap= "\<c-v>".amap
   endif
   let amap                    = a:maplead.amap
   let s:restoremap_{a:suffix} = s:restoremap_{a:suffix}."|:silent! ".mapmode."unmap ".dobuffer.amap
   if maparg(amap,mapmode) != ""
    let maprhs                  = substitute(maparg(amap,mapmode),'|','<bar>','ge')
	let s:restoremap_{a:suffix} = s:restoremap_{a:suffix}."|:".mapmode."map ".dobuffer.amap." ".maprhs
   endif
   if dounmap
	exe "silent! ".mapmode."unmap ".dobuffer.amap
   endif
 
  " save single map <something>
  elseif strpart(a:mapchx,0,1) == '<'
"   call Decho("save single map <something>")
   let amap       = a:mapchx
   if amap == "|" || amap == "\<c-v>"
    let amap= "\<c-v>".amap
"	call Decho("amap[[".amap."]]")
   endif
   let s:restoremap_{a:suffix} = s:restoremap_{a:suffix}."|silent! ".mapmode."unmap ".dobuffer.amap
   if maparg(a:mapchx,mapmode) != ""
    let maprhs                  = substitute(maparg(amap,mapmode),'|','<bar>','ge')
	let s:restoremap_{a:suffix} = s:restoremap_{a:suffix}."|".mapmode."map ".amap." ".dobuffer.maprhs
   endif
   if dounmap
	exe "silent! ".mapmode."unmap ".dobuffer.amap
   endif
 
  " save multiple maps
  else
"   call Decho("save multiple maps")
   let i= 1
   while i <= strlen(a:mapchx)
    let amap= a:maplead.strpart(a:mapchx,i-1,1)
	if amap == "|" || amap == "\<c-v>"
	 let amap= "\<c-v>".amap
	endif
	let s:restoremap_{a:suffix} = s:restoremap_{a:suffix}."|silent! ".mapmode."unmap ".dobuffer.amap
    if maparg(amap,mapmode) != ""
     let maprhs                  = substitute(maparg(amap,mapmode),'|','<bar>','ge')
	 let s:restoremap_{a:suffix} = s:restoremap_{a:suffix}."|".mapmode."map ".amap." ".dobuffer.maprhs
    endif
	if dounmap
	 exe "silent! ".mapmode."unmap ".dobuffer.amap
	endif
    let i= i + 1
   endwhile
  endif
"  call Dret("SaveUserMaps : restoremap_".a:suffix.": ".s:restoremap_{a:suffix})
endfun

" ---------------------------------------------------------------------
" RestoreUserMaps: {{{2
"   Used to restore user maps saved by SaveUserMaps()
fun! RestoreUserMaps(suffix)
"  call Dfunc("RestoreUserMaps(suffix<".a:suffix.">)")
  if exists("s:restoremap_{a:suffix}")
   let s:restoremap_{a:suffix}= substitute(s:restoremap_{a:suffix},'|\s*$','','e')
   if s:restoremap_{a:suffix} != ""
"   	call Decho("exe ".s:restoremap_{a:suffix})
    exe "silent! ".s:restoremap_{a:suffix}
   endif
   unlet s:restoremap_{a:suffix}
  endif
"  call Dret("RestoreUserMaps")
endfun

" ==============
"  Restore: {{{1
" ==============
let &cpo= s:keepcpo
unlet s:keepcpo

" ================
"  Modelines: {{{1
" ================
" vim: ts=4 fdm=marker
doc/Align.txt	[[[1
1469
*align.txt*	The Alignment Tool			Mar 04, 2009

Author:    Charles E. Campbell, Jr.  <NdrOchip@ScampbellPfamily.AbizM>
           (remove NOSPAM from Campbell's email first)
Copyright: (c) 2004-2008 by Charles E. Campbell, Jr.	*Align-copyright*
           The VIM LICENSE applies to Align.vim, AlignMaps.vim, and Align.txt
           (see |copyright|) except use "Align and AlignMaps" instead of "Vim"
           NO WARRANTY, EXPRESS OR IMPLIED.  USE AT-YOUR-OWN-RISK.

==============================================================================
1. Contents					*align* *align-contents* {{{1

	1. Contents.................: |align-contents|
	2. Alignment Manual.........: |align-manual|
	3. Alignment Usage..........: |align-usage|
	   Alignment Concepts.......: |align-concepts|
	   Alignment Commands.......: |align-commands|
	   Alignment Control........: |align-control|
	     Separators.............: |alignctrl-separators|
	     Initial Whitespace.....: |alignctrl-w| |alignctrl-W| |alignctrl-I|
	     Justification..........: |alignctrl-l| |alignctrl-r| |alignctrl-c|
	     Justification Control..: |alignctrl--| |alignctrl-+| |alignctrl-:|
	     Cyclic/Sequential......: |alignctrl-=| |alignctrl-C|
	     Separator Justification: |alignctrl-<| |alignctrl->| |alignctrl-||
	     Line (de)Selection.....: |alignctrl-g| |alignctrl-v|
	     Temporary Settings.....: |alignctrl-m|
	     Padding................: |alignctrl-p| |alignctrl-P|
	     Current Options........: |alignctrl-settings| |alignctrl-|
	   Alignment................: |align-align|
	4. Alignment Maps...........: |align-maps|
	     \a,....................: |alignmap-a,|
	     \a?....................: |alignmap-a?|
	     \a<....................: |alignmap-a<|
	     \abox..................: |alignmap-abox|
	     \acom..................: |alignmap-acom|
	     \anum..................: |alignmap-anum|
	     \ascom.................: |alignmap-ascom|
	     \adec..................: |alignmap-adec|
	     \adef..................: |alignmap-adef|
	     \afnc..................: |alignmap-afnc|
	     \adcom.................: |alignmap-adcom|
	     \aocom.................: |alignmap-aocom|
	     \tsp...................: |alignmap-tsp|
	     \tsq...................: |alignmap-tsq|
	     \tt....................: |alignmap-tt|
	     \t=....................: |alignmap-t=|
	     \T=....................: |alignmap-T=|
	     \Htd...................: |alignmap-Htd|
	5. Alignment Tool History...: |align-history|

==============================================================================
2. Align Manual			*alignman* *alignmanual* *align-manual* {{{1

	Align comes as a vimball; simply typing >
		vim Align.vba.gz
		:so %
<	should put its components where they belong.  The components are: >
		.vim/plugin/AlignPlugin.vim
		.vim/plugin/AlignMapsPlugin.vim
		.vim/plugin/cecutil.vim
		.vim/autoload/Align.vim
		.vim/autoload/AlignMaps.vim
		.vim/doc/Align.txt
<	To see a user's guide, see |align-userguide|
	To see examples, see |alignctrl| and |alignmaps|
>
/=============+=========+=====================================================\
||            \ Default/                                                     ||
||  Commands   \ Value/                Explanation                           ||
||              |    |                                                       ||
++==============+====+=======================================================++
||  AlignCtrl   |    |  =Clrc-+:pPIWw [..list-of-separator-patterns..]       ||
||              |    +-------------------------------------------------------+|
||              |    |  may be called as a command or as a function:         ||
||              |    |  :AlignCtrl =lp0P0W & \\                              ||
||              |    |  :call Align#AlignCtrl('=lp0P0W','&','\\')            ||
||              |    |                                                       ||
||              |    +-------------------------------------------------------++
||   1st arg    |  = | =  all separator patterns are equivalent and are      ||
||              |    |    simultaneously active. Patterns are |regexp|.      ||
||              |    | C  cycle through separator patterns.  Patterns are    ||
||              |    |    |regexp| and are active sequentially.              ||
||              |    |                                                       ||
||              |  < | <  left justify separator   Separators are justified, ||
||              |    | >  right justify separator  too.  Separator styles    ||
||              |    | |  center separator         are cyclic.               ||
||              |    |                                                       ||
||              |  l | l  left justify   Justification styles are always     ||
||              |    | r  right justify  cyclic (ie. lrc would mean left j., ||
||              |    | c  center         then right j., then center, repeat. ||
||              |    | -  skip this separator                                ||
||              |    | +  re-use last justification method                   ||
||              |    | :  treat rest of text as a field                      ||
||              |    |                                                       ||
||              | p1 | p### pad separator on left  by # blanks               ||
||              | P1 | P### pad separator on right by # blanks               ||
||              |    |                                                       ||
||              |  I | I  preserve and apply first line's leading white      ||
||              |    |    space to all lines                                 ||
||              |    | W  preserve leading white space on every line, even   ||
||              |    |    if it varies from line to line                     ||
||              |    | w  don't preserve leading white space                 ||
||              |    |                                                       ||
||              |    | g  second argument is a selection pattern -- only     ||
||              |    |    align on lines that have a match  (inspired by     ||
||              |    |    :g/selection pattern/command)                      ||
||              |    | v  second argument is a selection pattern -- only     ||
||              |    |    align on lines that _don't_ have a match (inspired ||
||              |    |    by :v/selection pattern/command)                   ||
||              |    |                                                       ||
||              |    | m  Map support: AlignCtrl will immediately do an      ||
||              |    |    AlignPush() and the next call to Align() will do   ||
||              |    |    an AlignPop at the end.  This feature allows maps  ||
||              |    |    to preserve user settings.                         ||
||              |    |                                                       ||
||              |    | default                                               ||
||              |    |    AlignCtrl default                                  ||
||              |    |    will clear the AlignCtrl                           ||
||              |    |    stack & set the default:  AlignCtrl "Ilp1P1=" '='  ||
||              |    |                                                       ||
||              +----+-------------------------------------------------------+|
||  More args   |  More arguments are interpreted as describing separators   ||
||              +------------------------------------------------------------+|
||   No args    |  AlignCtrl will display its current settings               ||
||==============+============================================================+|
||[range]Align  |   [..list-of-separators..]                                 ||
||[range]Align! |   [AlignCtrl settings] [..list-of-separators..]            ||
||              +------------------------------------------------------------+|
||              |  Aligns text over the given range.  The range may be       ||
||              |  selected via visual mode (v, V, or ctrl-v) or via         ||
||              |  the command line.  The Align operation may be invoked     ||
||              |  as a command or as a function; as a function, the first   ||
||              |  argument is 0=separators only, 1=AlignCtrl option string  ||
||              |  followed by a list of separators.                         ||
||              |   :[range]Align                                            ||
||              |   :[range]Align [list of separators]                       ||
||              |   :[range]call Align#Align(0)                              ||
||              |   :[range]call Align#Align(0,"list","of","separators",...) ||
\=============================================================================/

==============================================================================
3. Alignment Usage	*alignusage* *align-usage* *align-userguide* {{{1


ALIGNMENT CONCEPTS			*align-concept* *align-concepts* {{{2

	The typical text to be aligned is considered to be:

		* composed of two or more fields
		* separated by one or more separator pattern(s):
		* two or more lines
>
		ws field ws separator ws field ws separator ...
		ws field ws separator ws field ws separator ...
<
	where "ws" stands for "white space" such as blanks and/or tabs,
	and "fields" are arbitrary text.  For example, consider >

		x= y= z= 3;
		xx= yy= zz= 4;
		zzz= yyy= zzz= 5;
		a= b= c= 3;
<
	Assume that it is desired to line up all the "=" signs; these,
	then, are the separators.  The fields are composed of all the
	alphameric text.  Assuming they lie on lines 1-4, one may align
	those "=" signs with: >
		:AlignCtrl l
		:1,4Align =
<	The result is: >
		x   = y   = z   = 3;
		xx  = yy  = zz  = 4;
		zzz = yyy = zzz = 5;
		a   = b   = c   = 3;

<	Note how each "=" sign is surrounded by a single space; the
	default padding is p1P1 (p1 means one space before the separator,
	and P1 means one space after it).  If you wish to change the
	padding, say to no padding, use  (see |alignctrl-p|) >
		:AlignCtrl lp0P0

<	Next, note how each field is left justified; that's what the "l"
	(a small letter "ell") does.  If right-justification of the fields
	had been desired, an "r" could've been used: >
		:AlignCtrl r
<	yielding >
		  x =   y =   z = 3;
		 xx =  yy =  zz = 4;
		zzz = yyy = zzz = 5;
		  a =   b =   c = 3;
<	There are many more options available for field justification: see
	|alignctrl-c| and |alignctrl--|.

	Separators, although commonly only one character long, are actually
	specified by regular expressions (see |regexp|), and one may left
	justify, right justify, or center them, too (see |alignctrl-<|).

	Assume that for some reason a left-right-left-right-... justification
	sequence was wished.  This wish is simply achieved with >
		:AlignCtrl lr
		:1,4Align =
<	because the justification commands are considered to be "cylic"; ie.
	lr is the same as lrlrlrlrlrlrlr...

	There's a lot more discussed under |alignctrl|; hopefully the examples
	there will help, too.


ALIGNMENT COMMANDS			*align-command* *align-commands* {{{2

        The <Align.vim> script includes two primary commands and two
	minor commands:

	  AlignCtrl : this command/function sets up alignment options
	              which persist until changed for later Align calls.
		      It controls such things as: how to specify field
		      separators, initial white space, padding about
		      separators, left/right/center justification, etc. >
			ex.  AlignCtrl wp0P1
                             Interpretation: during subsequent alignment
			     operations, preserve each line's initial
			     whitespace.  Use no padding before separators
			     but provide one padding space after separators.
<
	  Align     : this command/function operates on the range given it to
		      align text based on one or more separator patterns.  The
		      patterns may be provided via AlignCtrl or via Align
		      itself. >

			ex. :%Align ,
			    Interpretation: align all commas over the entire
			    file.
<		      The :Align! format permits alignment control commands
		      to precede the alignment patterns. >
			ex. :%Align! p2P2 =
<		      This will align all "=" in the file with two padding
		      spaces on both sides of each "=" sign.

		      NOTE ON USING PATTERNS WITH ALIGN:~
		      Align and AlignCtrl use |<q-args>| to obtain their
		      input patterns and they use an internal function to
		      split arguments at whitespace unless inside "..."s.
		      One may escape characters inside a double-quote string
		      by preceding such characters with a backslash.

	  AlignPush : this command/function pushes the current AlignCtrl
	              state onto an internal stack. >
			ex. :AlignPush
			    Interpretation: save the current AlignCtrl
			    settings, whatever they may be.  They'll
			    also remain as the current settings until
			    AlignCtrl is used to change them.
<
	  AlignPop  : this command/function pops the current AlignCtrl
	              state from an internal stack. >
			ex. :AlignPop
			    Interpretation: presumably AlignPush was
			    used (at least once) previously; this command
			    restores the AlignCtrl settings when AlignPush
			    was last used.
<	              Also see |alignctrl-m| for a way to automatically do
	              an AlignPop after an Align (primarily this is for maps).

ALIGNMENT OPTIONS			*align-option* *align-options* {{{2
    *align-utf8* *align-utf* *align-codepoint* *align-strlen* *align-multibyte*

	For those of you who are using 2-byte (or more) characters such as are
	available with utf-8, Align now provides a special option which you
	may choose based upon your needs:

	Use Built-in strlen() ~
>
			let g:Align_xstrlen= 0

<       This is the fastest method, but it doesn't handle multibyte characters
	well.  It is the default for:

	  enc=latin1
	  vim compiled without multi-byte support
	  $LANG is en_US.UTF-8 (assuming USA english)

	Number of codepoints (Latin a + combining circumflex is two codepoints)~
>
			let g:Align_xstrlen= 1              (default)
<
	Number of spacing codepoints (Latin a + combining circumflex is one~
	spacing codepoint; a hard tab is one; wide and narrow CJK are one~
	each; etc.)~
>
			let g:Align_xstrlen= 2
<
	Virtual length (counting, for instance, tabs as anything between 1 and~
	'tabstop', wide CJK as 2 rather than 1, Arabic alif as zero when~
	immediately preceded by lam, one otherwise, etc.)~
>
			let g:Align_xstrlen= 3
<
	By putting one of these settings into your <.vimrc>, Align will use an
	internal (interpreted) function to determine a string's length instead
	of the Vim's built-in |strlen()| function.  Since the function is
	interpreted, Align will run a bit slower but will handle such strings
	correctly.  The last setting (g:Align_xstrlen= 3) probably will run
	the slowest but be the most accurate.  (thanks to Tony Mechelynck for
	these)


ALIGNMENT CONTROL				*alignctrl* *align-control* {{{2

	This command doesn't do the alignment operation itself; instead, it
	controls subsequent alignment operation(s).

	The first argument to AlignCtrl is a string which may contain one or
	more alignment control settings.  Most of the settings are specified
	by single letters; the exceptions are the p# and P# commands which
	interpret a digit following the p or P as specifying padding about the
	separator.

	The typical text line is considered to be composed of two or more
	fields separated by one or more separator pattern(s): >

		ws field ws separator ws field ws separator ...
<
	where "ws" stands for "white space" such as blanks and/or tabs.

	
	SEPARATORS				*alignctrl-separators* {{{3

	As a result, separators may not have white space (tabs or blanks) on
	their outsides (ie.  ":  :" is fine as a separator, but " :: " is
	not).  Usually such separators are not needed, although a map has been
	provided which works around this limitation and aligns on whitespace
	(see |alignmap-tsp|).

	However, if you really need to have separators with leading or
	trailing whitespace, consider handling them by performing a substitute
	first (ie. s/  ::  /@/g), do the alignment on the temporary pattern
	(ie. @), and then perform a substitute to revert the separators back
	to their desired condition (ie. s/@/  ::  /g).

	The Align#Align() function will first convert tabs over the region into
	spaces and then apply alignment control.  Except for initial white
	space, white space surrounding the fields is ignored.  One has three
	options just for handling initial white space:


	--- 						*alignctrl-w*
	wWI 	INITIAL WHITE SPACE			*alignctrl-W* {{{3
	--- 						*alignctrl-I*
		w : ignore all selected lines' initial white space
		W : retain all selected lines' initial white space
		I : retain only the first line's initial white space and
		    re-use it for subsequent lines

	Example: Leading white space options: >
                         +---------------+-------------------+-----------------+
	                 |AlignCtrl w= :=|  AlignCtrl W= :=  | AlignCtrl I= := |
      +------------------+---------------+-------------------+-----------------+
      |     Original     |   w option    |     W option      |     I option    |
      +------------------+---------------+-------------------+-----------------+
      |   a := baaa      |a     := baaa  |   a      : = baaa |   a     := baaa |
      | caaaa := deeee   |caaaa := deeee | caaaa    : = deeee|   caaaa := deeee|
      |       ee := f    |ee    := f     |       ee : = f    |   ee    := f    |
      +------------------+---------------+-------------------+-----------------+
<
	The original has at least one leading white space on every line.
	Using Align with w eliminated each line's leading white space.
	Using Align with W preserved  each line's leading white space.
	Using Align with I applied the first line's leading white space
	                   (three spaces) to each line.


	------						*alignctrl-l*
	lrc-+:	FIELD JUSTIFICATION			*alignctrl-r* {{{3
	------						*alignctrl-c*

	With "lrc", the fields will be left-justified, right-justified, or
	centered as indicated by the justification specifiers (lrc).  The
	"lrc" options are re-used by cycling through them as needed:

		l   means llllll....
		r   means rrrrrr....
		lr  means lrlrlr....
		llr means llrllr....

     Example: Justification options: Align = >
     +------------+-------------------+-------------------+-------------------+
     |  Original  |  AlignCtrl l      | AlignCtrl r       | AlignCtrl lr      |
     +------------+-------------------+-------------------+-------------------+
     | a=bb=ccc=1 |a   = bb  = ccc = 1|  a =  bb = ccc = 1|a   =  bb = ccc = 1|
     | ccc=a=bb=2 |ccc = a   = bb  = 2|ccc =   a =  bb = 2|ccc =   a = bb  = 2|
     | dd=eee=f=3 |dd  = eee = f   = 3| dd = eee =   f = 3|dd  = eee = f   = 3|
     +------------+-------------------+-------------------+-------------------+
     | Alignment  |l     l     l     l|  r     r     r   r|l       r   l     r|
     +------------+-------------------+-------------------+-------------------+
<
		AlignCtrl l : The = separator is repeatedly re-used, as the
			      cycle only consists of one character (the "l").
			      Every time left-justification is used for fields.
		AlignCtrl r : The = separator is repeatedly re-used, as the
			      cycle only consists of one character (the "l").
			      Every time right-justification is used for fields
		AlignCtrl lr: Again, the "=" separator is repeatedly re-used,
			      but the fields are justified alternately between
			      left and right.

	Even more separator control is available.  With "-+:":

	    - : skip treating the separator as a separator.   *alignctrl--*
	    + : repeat use of the last "lrc" justification    *alignctrl-+*
	    : : treat the rest of the line as a single field  *alignctrl-:*

     Example: More justification options:  Align = >
     +------------+---------------+--------------------+---------------+
     |  Original  |  AlignCtrl -l | AlignCtrl rl+      | AlignCtrl l:  |
     +------------+---------------+--------------------+---------------+
     | a=bb=ccc=1 |a=bb   = ccc=1 |  a = bb  = ccc = 1 |a   = bb=ccc=1 |
     | ccc=a=bb=2 |ccc=a  = bb=2  |ccc = a   = bb  = 2 |ccc = a=bb=2   |
     | dd=eee=f=3 |dd=eee = f=3   | dd = eee = f   = 3 |dd  = eee=f=3  |
     +------------+---------------+--------------------+---------------+
     | Alignment  |l        l     |  r   l     l     l |l     l        |
     +------------+---------------+--------------------+---------------+
<
	In the first example in "More justification options":

	  The first "=" separator is skipped by the "-" specification,
	  and so "a=bb", "ccc=a", and "dd=eee" are considered as single fields.

	  The next "=" separator has its (left side) field left-justified.
	  Due to the cyclic nature of separator patterns, the "-l"
	  specification is equivalent to "-l-l-l ...".

	  Hence the next specification is a "skip", so "ccc=1", etc are fields.

	In the second example in "More justification options":

	  The first field is right-justified, the second field is left
	  justified, and all remaining fields repeat the last justification
	  command (ie. they are left justified, too).

	  Hence rl+ is equivalent to         rlllllllll ...
	  (whereas plain rl is equivalent to rlrlrlrlrl ... ).

	In the third example in "More justification options":

	  The text following the first separator is treated as a single field.

	Thus using the - and : operators one can apply justification to a
	single separator.

	ex. 1st separator only:    AlignCtrl l:
	    2nd separator only:    AlignCtrl -l:
	    3rd separator only:    AlignCtrl --l:
	    etc.


	---						     *alignctrl-=*
	=C	CYCLIC VS ALL-ACTIVE SEPARATORS		     *alignctrl-C* {{{3
	---

	The separators themselves may be considered as equivalent and
	simultaneously active ("=") or sequentially cycled through ("C").
	Separators are regular expressions (|regexp|) and are specified as the
	second, third, etc arguments.  When the separator patterns are
	equivalent and simultaneously active, there will be one pattern
	constructed: >

		AlignCtrl ... pat1 pat2 pat3
		\(pat1\|pat2\|pat3\)
<
	Each separator pattern is thus equivalent and simultaneously active.
	The cyclic separator AlignCtrl option stores a list of patterns, only
	one of which is active for each field at a time.

	Example: Equivalent/Simultaneously-Active vs Cyclic Separators >
 +-------------+------------------+---------------------+----------------------+
 |   Original  | AlignCtrl = = + -| AlignCtrl = =       | AlignCtrl C = + -    |
 +-------------+------------------+---------------------+----------------------+
 |a = b + c - d|a = b + c - d     |a = b + c - d        |a = b         + c - d |
 |x = y = z + 2|x = y = z + 2     |x = y         = z + 2|x = y = z     + 2     |
 |w = s - t = 0|w = s - t = 0     |w = s - t     = 0    |w = s - t = 0         |
 +-------------+------------------+---------------------+----------------------+
<
	The original is initially aligned with all operators (=+-) being
	considered as equivalent and simultaneously active field separators.
	Thus the "AlignCtrl = = + -" example shows no change.

	The second example only accepts the '=' as a field separator;
	consequently "b + c - d" is now a single field.

	The third example illustrates cyclic field separators and is analyzed
	in the following illustration: >

	field1 separator field2    separator field3 separator field4
	   a      =      b             +       c        -       d
	   x      =      y = z         +       2
	   w      =      s - t = 0
<
	The word "cyclic" is used because the patterns form a cycle of use; in
	the above case, its = + - = + - = + - = + -...

	Example: Cyclic separators >
		Label : this is some text discussing ":"s | ex. abc:def:ghi
		Label : this is some text with a ":" in it | ex. abc:def
<
	  apply AlignCtrl lWC : | |
	        (select lines)Align >
                Label : this is some text discussing ":"s  | ex. abc:def:ghi
                Label : this is some text with a ":" in it | ex. abcd:efg
<
	In the current example,
	  : is the first separator        So the first ":"s are aligned
	  | is the second separator       but subsequent ":"s are not.
	  | is the third separator        The "|"s are aligned, too.
	  : is the fourth separator       Since there aren't two bars,
	  | is the fifth separator        the subsequent potential cycles
	  | is the sixth separator        don't appear.
	 ...

	In this case it would probably have been a better idea to have used >
		AlignCtrl WCl: : |
<	as that alignment control would guarantee that no more cycling
	would be used after the vertical bar.

	Example: Cyclic separators

	    Original: >
		a| b&c | (d|e) & f-g-h
		aa| bb&cc | (dd|ee) & ff-gg-hh
		aaa| bbb&ccc | (ddd|eee) & fff-ggg-hhh
<
	    AlignCtrl C | | & - >
		a   | b&c     | (d|e)     & f   - g-h
		aa  | bb&cc   | (dd|ee)   & ff  - gg-hh
		aaa | bbb&ccc | (ddd|eee) & fff - ggg-hhh
<
	In this example,
	the first and second separators are "|",
	the third            separator  is  "&", and
	the fourth           separator  is  "-",

	(cycling)
	the fifth and sixth  separators are "|",
	the seventh          separator  is  "&", and
	the eighth           separator  is  "-", etc.

	Thus the first "&"s are (not yet) separators, and hence are treated as
	part of the field.  Ignoring white space for the moment, the AlignCtrl
	shown here means that Align will work with >

	field | field | field & field - field | field | field & field - ...
<

	---						*alignctrl-<*
	<>|	SEPARATOR JUSTIFICATION			*alignctrl->* {{{3
	---						*alignctrl-|*

	Separators may be of differing lengths as shown in the example below.
	Hence they too may be justified left, right, or centered.
	Furthermore, separator justification specifications are cyclic:

		<  means <<<<<...    justify separator(s) to the left
		>  means >>>>>...    justify separator(s) to the right
		|  means |||||...    center separator(s)

	Example: Separator Justification: Align -\+ >
				+-----------------+
				|    Original     |
				+-----------------+
				| a - bbb - c     |
				| aa -- bb -- ccc |
				| aaa --- b --- cc|
	+---------------------+-+-----------------+-+---------------------+
	|     AlignCtrl <     |     AlignCtrl >     |     AlignCtrl |     |
	+---------------------+---------------------+---------------------+
	| a   -   bbb -   c   | a     - bbb   - c   | a    -  bbb  -  c   |
	| aa  --  bb  --  ccc | aa   -- bb   -- ccc | aa  --  bb  --  ccc |
	| aaa --- b   --- cc  | aaa --- b   --- cc  | aaa --- b   --- cc  |
	+---------------------+---------------------+---------------------+
<

	---						*alignctrl-g*
	gv	SELECTIVE APPLICATION			*alignctrl-v* {{{3
	---


	These two options provide a way to select (g) or to deselect (v) lines
	based on a pattern.  Ideally :g/pat/Align  would work; unfortunately
	it results in Align#Align() being called on each line satisfying the
	pattern separately. >

		AlignCtrl g pattern
<
	Align will only consider those lines which have the given pattern. >

		AlignCtrl v pattern
<
	Align will only consider those lines without the given pattern.  As an
	example of use, consider the following example: >

				           :AlignCtrl v ^\s*/\*
	  Original          :Align =       :Align =
	+----------------+------------------+----------------+
	|one= 2;         |one     = 2;      |one   = 2;      |
	|three= 4;       |three   = 4;      |three = 4;      |
	|/* skip=this */ |/* skip = this */ |/* skip=this */ |
	|five= 6;        |five    = 6;      |five  = 6;      |
	+----------------+------------------+----------------+
<
	The first "Align =" aligned with all "="s, including that one in the
	"skip=this" comment.

	The second "Align =" had a AlignCtrl v-pattern which caused it to skip
	(ignore) the "skip=this" line when aligning.
	
	To remove AlignCtrl's g and v patterns, use (as appropriate) >

		AlignCtrl g
		AlignCtrl v
<
	To see what g/v patterns are currently active, just use the reporting
	capability of an unadorned call to AlignCtrl: >

		AlignCtrl
<

	---
	 m	MAP SUPPORT				*alignctrl-m* {{{3
	---

	This option primarily supports the development of maps.  The
	Align#AlignCtrl() call will first do an Align#AlignPush() (ie. retain
	current alignment control settings).  The next Align#Align() will, in
	addition to its alignment job, finish up with an Align#AlignPop().
	Thus the Align#AlignCtrl settings that follow the "m" are only
	temporarily in effect for just the next Align#Align().


	---
	p###						*alignctrl-p*
	P###	PADDING					*alignctrl-P* {{{3
	---

	These two options control pre-padding and post-padding with blanks
	about the separator.  One may pad separators with zero to nine spaces;
	the padding number(s) is/are treated as a cyclic parameter.  Thus one
	may specify padding separately for each field or re-use a padding
	pattern. >

	Example:          AlignCtrl p102P0
	+---------+----------------------------------+
	| Original| a=b=c=d=e=f=g=h=1                |
        | Align = | a =b=c  =d =e=f  =g =h=1         |
        +---------+----------------------------------+
	| prepad  |   1 0   2  1 0   2  1 0          |
        +---------+----------------------------------+
<
	This example will cause Align to:

		pre-pad the first  "=" with a single blank,
		pre-pad the second "=" with no blanks,
		pre-pad the third  "=" with two blanks,
		pre-pad the fourth "=" with a single blank,
		pre-pad the fifth  "=" with no blanks,
		pre-pad the sixth  "=" with two blanks,
	        etc.

	---------------				*alignctrl-settings*
	No option given		DISPLAY STATUS	*alignctrl-*		{{{3
	---------------				*alignctrl-no-option*

	AlignCtrl, when called with no arguments, will display the current
	alignment control settings.  A typical display is shown below: >

		AlignCtrl<=> qty=1 AlignStyle<l> Padding<1|1>
		Pat1<\(=\)>
<
	Interpreting, this means that the separator patterns are all
	equivalent; in this case, there's only one (qty=1).  Fields will be
	padded on the right with spaces (left justification), and separators
	will be padded on each side with a single space.

	To change one of these items, see:

	  AlignCtrl......|alignctrl|
	  qty............|align-concept|
	  AlignStyle.....|alignctrl--| |alignctrl-+| |alignctrl-:||alignctrl-c|
	  Padding........|alignctrl-p| |alignctrl-P|

	One may get a string which can be fed back into AlignCtrl: >

		:let alignctrl= Align#AlignCtrl()
<
	This form will put a string describing the current AlignCtrl options,
	except for the "g" and "v" patterns, into a variable.  The
	Align#AlignCtrl() function will still echo its settings, however.  One
	can feed any non-supported "option" to AlignCtrl() to prevent this,
	however: >

		:let alignctrl= Align#AlignCtrl("d")
<

ALIGNMENT						*align-align* {{{2

	Once the alignment control has been determined, the user specifies a
	range of lines for the Align command/function to do its thing.
	Alignment is often done on a line-range basis, but one may also
	restrict alignment to a visual block using ctrl-v.  For any visual
	mode, one types the colon (:) and then "Align".  One may, of course,
	specify a range of lines: >

		:[range]Align [list-of-separators]
<
	where the |:range| is the usual Vim-powered set of possibilities; the
	list of separators is the same as the AlignCtrl capability.  There is
	only one list of separators, but either AlignCtrl or Align can be used
	to specify that list.

	An alternative form of the Align command can handle both alignment
	control and the separator list: >

		:[range]Align! [alignment-control-string] [list-of-separators]
<
	The alignment control string will be applied only for this particular
	application of Align (it uses |alignctrl-m|).  The "g pattern" and
	"v pattern" alignment controls (see |alignctrl-g| and |alignctrl-v|)
	are also available via this form of the Align command.

	Align makes two passes over the text to be aligned.  The first pass
	determines how many fields there are and determines the maximum sizes
	of each field; these sizes are then stored in a vector.  The second
	pass pads the field (left/right/centered as specified) to bring its
	length up to the maximum size of the field.  Then the separator and
	its AlignCtrl-specified padding is appended.

		Pseudo-Code:~
		 During pass 1
		 | For all fields in the current line
		 || Determine current separator
		 || Examine field specified by current separator
		 || Determine length of field and save if largest thus far
		 Initialize newline based on initial whitespace option (wWI)
		 During pass 2
		 | For all fields in current line
		 || Determine current separator
		 || Extract field specified by current separator
		 || Prepend/append padding as specified by AlignCtrl
		 || (right/left/center)-justify to fit field into max-size field
		 || Append separator with AlignCtrl-specified separator padding
		 || Delete current line, install newly aligned line

	The g and v AlignCtrl patterns cause the passes not to consider lines
	for alignment, either by requiring that the g-pattern be present or
	that the v-pattern not be present.

	The whitespace on either side of a separator is ignored.


==============================================================================
4. Alignment Maps				*alignmaps* *align-maps* {{{1

	There are a number of maps using Align#AlignCtrl() and Align#Align()
	in the <AlignMapsPlugin.vim> file.  This file may also be put into the
	plugins subdirectory.  Since AlignCtrl and Align supercede textab and
	its <ttalign.vim> file, the maps either have a leading "t" (for
	"textab") or the more complicated ones an "a" (for "alignment") for
	backwards compatibility.

	The maps are shown below with a leading backslash (\).  Actually, the
	<Leader> construct is used (see |mapleader|), so the maps' leading
	kick-off character is easily customized.

	Furthermore, all AlignMapsPlugin.vim maps use the <Plug> construct (see
	|<Plug>|and |usr_41.txt|).  Hence, if one wishes to override the
	mapping entirely, one may do that, too.  As an example: >
		map <Leader>ACOM	<Plug>AM_acom
<	would have \ACOM do what \acom previously did (assuming that the
	mapleader has been left at its default value of a backslash).

	  \a,   : useful for breaking up comma-separated
	          declarations prior to \adec			|alignmap-a,|
	  \a(   : aligns ( and , (useful for prototypes)        *alignmap-a(*
	  \a?   : aligns (...)? ...:... expressions on ? and :	|alignmap-a?|
	  \a<   : aligns << and >> for c++			|alignmap-a<|
	  \a=   : aligns := assignments   			|alignmap-a=|
	  \abox : draw a C-style comment box around text lines	|alignmap-abox|
	  \acom : useful for aligning comments			|alignmap-acom|
	  \adcom: useful for aligning comments in declarations  |alignmap-adcom|
	  \anum : useful for aligning numbers 			|alignmap-anum|
	          NOTE: For the visual-mode use of \anum, <vis.vim> is needed!
		    See http://mysite.verizon.net/astronaut/vim/index.html#VIS
	  \aenum: align a European-style number			|alignmap-anum|
	  \aunum: align a USA-style number			|alignmap-anum|
	  \adec : useful for aligning declarations		|alignmap-adec|
	  \adef : useful for aligning definitions		|alignmap-adef|
	  \afnc : useful for aligning ansi-c style functions'
	          argument lists				|alignmap-afnc|
	  \adcom: a variant of \acom, restricted to comment     |alignmap-adcom|
	          containing lines only, but also only for
		  those which don't begin with a comment.
		  Good for certain declaration styles.
	  \aocom: a variant of \acom, restricted to comment     |alignmap-aocom|
	          containing lines only
	  \tab  : align a table based on tabs			*alignmap-tab*
	          (converts to spaces)
	  \tml  : useful for aligning the trailing backslashes	|alignmap-tml|
	          used to continue lines (shell programming, etc)
	  \tsp  : use Align to make a table separated by blanks	|alignmap-tsp|
	          (left justified)
	  \ts,  : like \t, but swaps whitespace on the right of *alignmap-ts,*
	          the commas to their left
	  \ts:  : like \t: but swaps whitespace on the right of *alignmap-ts:*
	          the colons to their left
	  \ts<  : like \t< but swaps whitespace on the right of *alignmap-ts<*
	          the less-than signs to their left
	  \ts=  : like \t= but swaps whitespace on the right of *alignmap-ts=*
	          the equals signs to their left
	  \Tsp  : use Align to make a table separated by blanks	|alignmap-Tsp|
	          (right justified)
	  \tsq  : use Align to make a table separated by blanks	|alignmap-tsq|
	          (left justified) -- "strings" are not split up
	  \tt   : useful for aligning LaTeX tabular tables	|alignmap-tt|
	  \Htd  : tabularizes html tables:			|alignmap-Htd|
	          <TR><TD> ...field... </TD><TD> ...field... </TD></TR>

		  *alignmap-t|* *alignmap-t#* *alignmap-t,* *alignmap-t:*
		  *alignmap-t;* *alignmap-t<* *alignmap-t?* *alignmap-t~*
		  *alignmap-m=*
	  \tx   : make a left-justified  alignment on
	          character "x" where "x" is: ,:<=@|#		|alignmap-t=|
	  \Tx   : make a right-justified alignment on
	          character "x" where "x" is: ,:<=@#		|alignmap-T=|
	  \m=   : like \t= but aligns with %... style comments

	The leading backslash is actually <leader> (see |mapleader| for how to
	customize the leader to be whatever you like).  These maps use the
	<Align.vim> package and are defined in the <AlignMaps.vim> file.
	Although the maps use AlignCtrl options, they typically use the "m"
	option which pushes the options (AlignPush).  The associated Align
	call which follows will then AlignPop the user's original options
	back.

	ALIGNMENT MAP USE WITH MARK AND MOVE~
	In the examples below, one may select the text with a "ma" at the
	first line, move to the last line, then execute the map.

	ALIGNMENT MAP USE WITH VISUAL MODE~
	Alternatively, one may select the text with the "V" visual mode
	command.

	ALIGNMENT MAP USE WITH MENUS~
	One may use the mark-and-move style (ma, move, use the menu) or
	the visual mode style (use the V visual mode, move, then select
	the alignment map with menu selection).  The alignment map menu
	items are under DrChip.AlignMaps .

	One may even change the top level menu name to whatever is wished; by
	default, its >
		let g:DrChipTopLvlMenu= "DrChip."
<	If you set the variable to the empty string (""), then no menu items
	will be produced.  Of course, one must have a vim with +menu, the gui
	must be running, and |'go'| must have the menu bar suboption (ie. m
	must be included).

	COMPLEX ALIGNMENT MAP METHOD~

	For those complex alignment maps which do alignment on constructs
	(e.g. \acom, \adec, etc), a series of substitutes is used to insert
	"@" symbols in appropriate locations.  Align#Align() is then used to
	do alignment directly on "@"s; then it is followed by further
	substitutes to do clean-up.  However, the maps \WS and \WE, used by
	every map supported by AlignMaps, protect any original embedded "@"
	symbols by first converting them to <DEL> characters, doing the
	requested job, and then converting them back. >

	    \WS  calls AlignMaps#WrapperStart()
	    \WE  calls AlignMaps#WrapperEnd()
<

	---------------------------
	Alignment Map Examples: \a,			*alignmap-a,* {{{3
	---------------------------

	Original: illustrates comma-separated declaration splitting: >
		int a,b,c;
		struct ABC_str abc,def;
<
	Becomes: >
		int a;
		int b;
		int c;
		struct ABC_str abc;
		struct ABC_str def;
<

	---------------------------
	Alignment Map Examples: \a?			*alignmap-a?* {{{3
	---------------------------

	Original: illustrates ()?: aligning >
		printf("<%s>\n",
		  (x == ABC)? "abc" :
		  (x == DEFG)? "defg" :
		  (x == HIJKL)? "hijkl" : "???");
<
	Becomes:  select "(x == ..." lines, then \a? >
		printf("<%s>\n",
		  (x == ABC)?   "abc"   :
		  (x == DEFG)?  "defg"  :
		  (x == HIJKL)? "hijkl" : "???");
<

	---------------------------
	Alignment Map Examples: \a<			*alignmap-a<* {{{3
	---------------------------

	Original: illustrating aligning of << and >> >
		cin << x;
		cin      << y;
		cout << "this is x=" << x;
		cout << "but y=" << y << "is not";
<
	Becomes:  select "(x == ..." lines, then \a< >
		cin  << x;
		cin  << y;
		cout << "this is x=" << x;
		cout << "but y="     << y  << "is not";
<

	---------------------------
	Alignment Map Examples: \a=			*alignmap-a=* {{{3
	---------------------------

	Original: illustrates how to align := assignments >
		aa:=bb:=cc:=1;
		a:=b:=c:=1;
		aaa:=bbb:=ccc:=1;
<	
	Bcomes: select the three assignment lines, then \a:= >
		aa  := bb  := cc  := 1;
		a   := b   := c   := 1;
		aaa := bbb := ccc := 1;
<

	---------------------------
	Alignment Map Examples: \abox			*alignmap-abox* {{{3
	---------------------------

	Original: illustrates how to comment-box some text >
		This is some plain text
		which will
		soon be surrounded by a
		comment box.
<
	Becomes:  Select "This..box." with ctrl-v, press \abox >
		/***************************
		 * This is some plain text *
		 * which will              *
		 * soon be surrounded by a *
		 * comment box.            *
		 ***************************/
<

	---------------------------
	Alignment Map Examples: \acom			*alignmap-acom* {{{3
	---------------------------

	Original: illustrates aligning C-style comments (works for //, too) >
		if(itworks) { /* this */
			then= dothis; /* is a */
			} /* set of three comments */
<
	Becomes: Select the three lines, press \acom >
	        if(itworks) {         /* this                  */
	                then= dothis; /* is a                  */
	                }             /* set of three comments */
<
	Also see |alignmap-aocom|


	---------------------------
	Alignment Map Examples: \anum			*alignmap-anum* {{{3
	---------------------------

	Original: illustrates how to get numbers lined up >
		 -1.234 .5678 -.901e-4
		 1.234 5.678 9.01e-4
		 12.34 56.78 90.1e-4
		 123.4 567.8 901.e-4
<
	Becomes: Go to first line, ma.  Go to last line, press \anum >
		  -1.234    .5678   -.901e-4
		   1.234   5.678    9.01e-4
		  12.34   56.78    90.1e-4
		 123.4   567.8    901.e-4
<
	Original: >
		 | -1.234 .5678 -.901e-4 |
		 | 1.234 5.678 9.01e-4   |
		 | 12.34 56.78 90.1e-4   |
		 | 123.4 567.8 901.e-4   |
<
	Becomes: Select the numbers with ctrl-v (visual-block mode), >
	         press \anum
	         |  -1.234    .5678   -.901e-4 |
	         |   1.234   5.678    9.01e-4  |
	         |  12.34   56.78    90.1e-4   |
	         | 123.4   567.8    901.e-4    |
<
	Original: >
		 -1,234 ,5678 -,901e-4
		 1,234 5,678 9,01e-4
		 12,34 56,78 90,1e-4
		 123,4 567,8 901,e-4
<
	Becomes: Go to first line, ma.  Go to last line, press \anum >
		  -1,234    ,5678   -,901e-4
		   1,234   5,678    9,01e-4
		  12,34   56,78    90,1e-4
		 123,4   567,8    901,e-4
<
	In addition:
	  \aenum is provided to support European-style numbers
	  \aunum is provided to support USA-style numbers

	One may get \aenum behavior for \anum >
	  let g:alignmaps_euronumber= 1
<	or \aunum behavior for \anum if one puts >
	  let g:alignmaps_usanumber= 1
<	in one's <.vimrc>.


	---------------------------
	Alignment Map Examples: \ascom			*alignmap-ascom* {{{3
	---------------------------

	Original: >
		/* A Title */
		int x; /* this is a comment */
		int yzw; /* this is another comment*/
<
	Becomes: Select the three lines, press \ascom >
	        /* A Title */
	        int x;   /* this is a comment       */
	        int yzw; /* this is another comment */
<

	---------------------------
	Alignment Map Examples: \adec			*alignmap-adec* {{{3
	---------------------------

	Original: illustrates how to clean up C/C++ declarations >
		int     a;
		float   b;
		double *c=NULL;
		char x[5];
		struct  abc_str abc;
		struct  abc_str *pabc;
		int     a;              /* a   */
		float   b;              /* b   */
		double *c=NULL;              /* b   */
		char x[5]; /* x[5] */
		struct  abc_str abc;    /* abc */
		struct  abc_str *pabc;    /* pabc */
		static   int     a;              /* a   */
		static   float   b;              /* b   */
		static   double *c=NULL;              /* b   */
		static   char x[5]; /* x[5] */
		static   struct  abc_str abc;    /* abc */
		static   struct  abc_str *pabc;    /* pabc */
<
	Becomes: Select the declarations text, then \adec >
		int                    a;
		float                  b;
		double                *c    = NULL;
		char                   x[5];
		struct abc_str         abc;
		struct abc_str        *pabc;
		int                    a;           /* a    */
		float                  b;           /* b    */
		double                *c    = NULL; /* b    */
		char                   x[5];        /* x[5] */
		struct abc_str         abc;         /* abc  */
		struct abc_str        *pabc;        /* pabc */
		static int             a;           /* a    */
		static float           b;           /* b    */
		static double         *c    = NULL; /* b    */
		static char            x[5];        /* x[5] */
		static struct abc_str  abc;         /* abc  */
		static struct abc_str *pabc;        /* pabc */
<

	---------------------------
	Alignment Map Examples: \adef			*alignmap-adef* {{{3
	---------------------------

	Original: illustrates how to line up #def'initions >
		#define ONE 1
		#define TWO 22
		#define THREE 333
		#define FOUR 4444
<
	Becomes: Select four definition lines, apply \adef >
	#	 define ONE   1
	#	 define TWO   22
	#	 define THREE 333
	#	 define FOUR  4444
<

	---------------------------
	Alignment Map Examples: \afnc			*alignmap-afnc* {{{3
	---------------------------

	This map is an exception to the usual selection rules.
	It uses "]]" to find the function body's leading "{".
	Just put the cursor anywhere in the function arguments and
	the entire function declaration should be processed.

	Because "]]" looks for that "{" in the first column, the
	"original" and "becomes" examples are in the first column,
	too.

	Original: illustrates lining up ansi-c style function definitions >
	int f(
	  struct abc_str ***a, /* one */
	  long *b, /* two */
	  int c) /* three */
	{
	}
<
	Becomes: put cursor anywhere before the '{', press \afnc >
	int f(
	  struct abc_str ***a,	/* one   */
	  long             *b,	/* two   */
	  int               c)	/* three */
	{
	}
<

	---------------------------
	Alignment Map Examples: \adcom			*alignmap-adcom* {{{3
	---------------------------

	Original: illustrates aligning comments that don't begin
		lines (optionally after some whitespace). >
		struct {
			/* this is a test */
			int x; /* of how */
			double y; /* to use adcom */
			};
<
	Becomes: Select the inside lines of the structure,
		then press \adcom.  The comment-only
		line is ignored but the other two comments
		get aligned. >
		struct {
                        /* this is a test */
                        int x;    /* of how       */
                        double y; /* to use adcom */
			};
<

	---------------------------
	Alignment Map Examples: \aocom			*alignmap-aocom* {{{3
	---------------------------

	Original: illustrates how to align C-style comments (works for //, too)
	          but restricted only to aligning with those lines containing
		  comments.  See the difference from \acom (|alignmap-acom|). >
		if(itworks) { /* this comment */
			then= dothis;
			} /* only appears on two lines */
<
	Becomes: Select the three lines, press \aocom >
                if(itworks) { /* this comment              */
                        then= dothis;
                        }     /* only appears on two lines */
<
	Also see |alignmap-acom|


	---------------------------			*alignmap-Tsp*
	Alignment Map Examples: \tsp			*alignmap-tsp* {{{3
	---------------------------

	Normally Align can't use white spaces for field separators as such
	characters are ignored surrounding field separators.  The \tsp and
	\Tsp maps get around this limitation.

	Original: >
	 one two three four five
	 six seven eight nine ten
	 eleven twelve thirteen fourteen fifteen
<
	Becomes: Select the lines, \tsp >
	 one    two    three    four     five
	 six    seven  eight    nine     ten
	 eleven twelve thirteen fourteen fifteen
<
	Becomes: Select the lines, \Tsp >
	    one    two    three     four    five
	    six  seven    eight     nine     ten
	 eleven twelve thirteen fourteen fifteen
<

	---------------------------
	Alignment Map Examples: \tsq			*alignmap-tsq* {{{3
	---------------------------

	The \tsp map is useful for aligning tables based on white space,
	but sometimes one wants double-quoted strings to act as a single
	object in spite of embedded spaces.  The \tsq map was invented
	to support this. (thanks to Leif Wickland)

	Original: >
	 "one two" three
	 four "five six"
<
	Becomes: Select the lines, \tsq >
	 "one two" three
	 four      "five six"
<

	---------------------------
	Alignment Map Examples: \tt			*alignmap-tt* {{{3
	---------------------------

	Original: illustrates aligning a LaTex Table >
	 \begin{tabular}{||c|l|r||}
	 \hline\hline
	   one&two&three\\ \hline
	   four&five&six\\
	   seven&eight&nine\\
	 \hline\hline
	 \end{tabular}
<
	Becomes: Select the three lines inside the table >
	(ie. one..,four..,seven..) and press \tt
	 \begin{tabular}{||c|l|r||}
	 \hline\hline
	   one   & two   & three \\ \hline
	   four  & five  & six   \\
	   seven & eight & nine  \\
	 \hline\hline
	 \end{tabular}
<

	----------------------------
	Alignment Map Examples: \tml			*alignmap-tml* {{{3
	----------------------------

        Original:  illustrates aligning multi-line continuation marks >
	one \
	two three \
	four five six \
	seven \\ \
	eight \nine \
	ten \
<
        Becomes:  >
        one           \
        two three     \
        four five six \
        seven \\      \
        eight \nine   \
        ten           \
<

	---------------------------
	Alignment Map Examples: \t=			*alignmap-t=* {{{3
	---------------------------

	Original: illustrates left-justified aligning of = >
		aa=bb=cc=1;/*one*/
		a=b=c=1;/*two*/
		aaa=bbb=ccc=1;/*three*/
<
	Becomes: Select the three equations, press \t= >
		aa  = bb  = cc  = 1; /* one   */
		a   = b   = c   = 1; /* two   */
		aaa = bbb = ccc = 1; /* three */
<

	---------------------------
	Alignment Map Examples: \T=			*alignmap-T=* {{{3
	---------------------------

	Original: illustrates right-justified aligning of = >
		aa=bb=cc=1; /* one */
		a=b=c=1; /* two */
		aaa=bbb=ccc=1; /* three */
<
	Becomes: Select the three equations, press \T= >
                 aa =  bb =  cc = 1; /* one   */
                  a =   b =   c = 1; /* two   */
                aaa = bbb = ccc = 1; /* three */
<

	---------------------------
	Alignment Map Examples: \Htd			*alignmap-Htd* {{{3
	---------------------------

	Original: for aligning tables with html >
	  <TR><TD>...field one...</TD><TD>...field two...</TD></TR>
	  <TR><TD>...field three...</TD><TD>...field four...</TD></TR>
<
	Becomes: Select <TR>... lines, press \Htd >
	  <TR><TD> ...field one...   </TD><TD> ...field two...  </TD></TR>
	  <TR><TD> ...field three... </TD><TD> ...field four... </TD></TR>
<
==============================================================================
4. Alignment Tools' History				*align-history* {{{1

ALIGN HISTORY								{{{2
	35 : Nov 02, 2008 * g:loaded_AlignPlugin testing to prevent re-loading
			    installed
	     Nov 19, 2008 * new sanity check for an AlignStyle of just ":"
	     Jan 08, 2009 * save&restore of |'mod'| now done with local
			    variant
	34 : Jul 08, 2008 * using :AlignCtrl before entering any alignment
			    control commands was causing an error.
	33 : Sep 20, 2007 * s:Strlen() introduced to support various ways
			    used to represent characters and their effects
			    on string lengths.  See |align-strlen|.
			  * Align now accepts "..." -- so it can accept
			    whitespace as separators.
	32 : Aug 18, 2007 * uses |<q-args>| instead of |<f-args>| plus a
	                    custom argument splitter to allow patterns with
			    backslashes to slide in unaltered.
	31 : Aug 06, 2007 * :[range]Align! [AlignCtrl settings] pattern(s)
	                    implemented.
	30 : Feb 12, 2007 * now uses |setline()|
	29 : Jan 18, 2006 * cecutil updated to use keepjumps
	     Feb 23, 2006 * Align now converted to vim 7.0 style using
	                    auto-loading functions.
	28 : Aug 17, 2005 * report option workaround
	     Oct 24, 2005 * AlignCtrl l:  wasn't behaving as expected; fixed
	27 : Apr 15, 2005 : cpo workaround
	                    ignorecase workaround
	26 : Aug 20, 2004 : loaded_align now also indicates version number
	                    GetLatestVimScripts :AutoInstall: now supported
	25 : Jul 27, 2004 : For debugging, uses Dfunc(), Dret(), and Decho()
	24 : Mar 03, 2004 : (should've done this earlier!) visualmode(1)
	                    not supported until v6.2, now Align will avoid
			    calling it for earlier versions.  Visualmode
			    clearing won't take place then, of course.
	23 : Oct 07, 2003 : Included Leif Wickland's ReplaceQuotedSpaces()
	                    function which supports \tsq
	22 : Jan 29, 2003 : Now requires 6.1.308 or later to clear visualmode()
	21 : Jan 10, 2003 : BugFix: similar problem to #19; new code
	                    bypasses "norm! v\<Esc>" until initialization
	                    is over.
	20 : Dec 30, 2002 : BugFix: more on "unable to highlight" fixed
	19 : Nov 21, 2002 : BugFix: some terminals gave an "unable to highlight"
	                    message at startup; Hari Krishna Dara tracked it
	                    down; a silent! now included to prevent noise.
	18 : Nov 04, 2002 : BugFix: re-enabled anti-repeated-loading
	17 : Nov 04, 2002 : BugFix: forgot to have AlignPush() push s:AlignSep
	                    AlignCtrl now clears visual-block mode when used so
	                    that Align won't try to use old visual-block
	                    selection marks '< '>
	16 : Sep 18, 2002 : AlignCtrl <>| options implemented (separator
	                    justification)
	15 : Aug 22, 2002 : bug fix: AlignCtrl's ":" now acts as a modifier of
	                             the preceding alignment operator (lrc)
	14 : Aug 20, 2002 : bug fix: AlignCtrl default now keeps &ic unchanged
	                    bug fix: Align, on end-field, wasn't using correct
	                    alignop bug fix: Align, on end-field, was appending
			    padding
	13 : Aug 19, 2002 : bug fix: zero-length g/v patterns are accepted
	                    bug fix: always skip blank lines
	                    bug fix: AlignCtrl default now also clears g and v
	                             patterns
	12 : Aug 16, 2002 : moved keep_ic above zero-length pattern checks
	                    added "AlignCtrl default"
	                    fixed bug with last field getting separator spaces
	                    at end line
	11 : Jul 08, 2002 : prevent separator patterns which match zero length
	                    -+: included as additional alignment/justification
	                    styles
	10 : Jun 26, 2002 : =~# used instead of =~ (for matching case)
	                    ignorecase option handled
	 9 : Jun 25, 2002 : implemented cyclic padding

ALIGNMENT MAP HISTORY					*alignmap-history* {{{2
       v41    Nov 02, 2008   * g:loaded_AlignMapsPlugin testing to prevent
			       re-loading installed
			     * AlignMaps now use 0x0f (ctrl-p) for special
			       character substitutions (instead of 0xff).
			       Seems to avoid some problems with having to
			       use Strlen().
			     * bug fixed with \ts,
			     * new maps: \ts; \ts, \ts: \ts< \ts= \a(
       v40    Oct 21, 2008   * Modified AlignMaps so that its maps use <Plug>s
			       and <script>s.  \t@ and related maps have been
			       changed to call StdAlign() instead.  The
			       WrapperStart function now takes an argument and
			       handles being called via visual mode.  The
			       former nmaps and vmaps have thus been replaced
			       with a simple map.
	      Oct 24, 2008   * broke AlignMaps into a plugin and autoload
			       pair of scripts.
	v39   Mar 06, 2008 : * \t= only does /* ... */ aligning when in *.c
	                       *.cpp files.
	v38   Aug 18, 2007 : * \tt altered so that it works with the new
	                       use of |<q-args>| plus a custom argument
			       splitter
	v36   Sep 27, 2006 : * AlignWrapperStart() now has tests that marks
	                       y and z are not set
	      May 15, 2007   * \anum and variants improved
	v35   Sep 01, 2006 : * \t= and cousins used "`"s.  They now use \xff
	                       characters.
	                     * \acom now works with doxygen style /// comments
	                     * <char-0xff> used in \t= \T= \w= and \m= instead
	                       of backquotes.
	v34   Feb 23, 2006 : * AlignMaps now converted to vim 7.0 style using
	                       auto-loading functions.
	v33   Oct 12, 2005 : * \ts, now uses P1 in its AlignCtrl call
	v32   Jun 28, 2005 : * s:WrapperStart() changed to AlignWrapperStart()
	                       s:WrapperEnd() changed to AlignWrapperEnd()
	                       These changes let the AlignWrapper...()s to be
	                       used outside of AlignMaps.vim
	v31   Feb 01, 2005 : * \adcom included, with help
	                     * \a, now works across multiple lines with
	                       different types
	                     * AlignMaps now uses <cecutil.vim> for its mark and
	                       window-position saving and restoration
	      Mar 04, 2005   * improved \a,
	      Apr 06, 2005   * included \aenum, \aunum, and provided
	              g:alignmaps_{usa|euro]number} options
	v30   Aug 20, 2004 : * \a, : handles embedded assignments and does \adec
	                     * \acom  now can handle Doxygen-style comments
	                     * g:loaded_alignmaps now also indicates version
	                     * internal maps \WE and \WS are now re-entrant
	v29   Jul 27, 2004 : * \tml aligns trailing multi-line single
	                      backslashes (thanks to Raul Benavente!)
	v28   May 13, 2004 : * \a, had problems with leading blanks; fixed!
	v27   Mar 31, 2004 : * \T= was having problems with == and !=
	                     * Fixed more problems with \adec
	v26   Dec 09, 2003 : * \ascom now also ignores lines without comments
	                     * \tt  \& now not matched
	                     * \a< handles both << and >>
	v25   Nov 14, 2003 : * included \anum (aligns numbers with periods and
	                       commas).  \anum also supported with ctrl-v mode.
	                     * \ts, \Ts, : (aligns on commas, then swaps leading
	                       spaces with commas)
	                     * \adec ignores preprocessor lines and lines with
	                       with comments-only
	v23   Sep 10, 2003 : * Bugfix for \afnc - no longer overwrites marks y,z
	                     * fixed bug in \tsp, \tab, \Tsp, and \Tab - lines
	                       containing backslashes were having their
	                       backslashes removed.  Included Leif Wickland's
	                       patch for \tsq.
	                     * \adef now ignores lines holding comments only
	v18   Aug 22, 2003 :   \a< lines up C++'s << operators
	                       saves/restores gdefault option (sets to nogd)
	                       all b:..varname.. are now b:alignmaps_..varname..
	v17   Nov 04, 2002 :   \afnc now handles // comments correctly and
	                       commas within comments
	v16   Sep 10, 2002 :   changed : to :silent! for \adec
	v15   Aug 27, 2002 :   removed some <c-v>s
	v14   Aug 20, 2002 :   \WS, \WE mostly moved to functions, marks y and z
	                       now restored
	v11   Jul 08, 2002 :   \abox bug fix
	 v9   Jun 25, 2002 :   \abox now handles leading initial whitespace
	                   :   various bugfixes to \afnc, \T=, etc

==============================================================================
Modelines: {{{1
vim:tw=78:ts=8:ft=help:fdm=marker:

