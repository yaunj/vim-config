" AlignMapsPlugin:   Alignment maps based upon <Align.vim> and <AlignMaps.vim>
" Maintainer:        Dr. Charles E. Campbell, Jr. <NdrOchipS@PcampbellAfamily.Mbiz>
" Date:              Mar 03, 2009
"
" NOTE: the code herein needs vim 6.0 or later
"                       needs <Align.vim> v6 or later
"                       needs <cecutil.vim> v5 or later
" Copyright:    Copyright (C) 1999-2008 Charles E. Campbell, Jr. {{{1
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               AlignMaps.vim is provided *as is* and comes with no warranty
"               of any kind, either expressed or implied. By using this
"               plugin, you agree that in no event will the copyright
"               holder be liable for any damages resulting from the use
"               of this software.
"
" Usage: {{{1
" Use 'a to mark beginning of to-be-aligned region,   Alternative:  use V
" move cursor to end of region, and execute map.      (linewise visual mode) to
" The maps also set up marks 'y and 'z, and retain    mark region, execute same
" 'a at the beginning of region.                      map.  Uses 'a, 'y, and 'z.
"
" The start/end wrappers save and restore marks 'y and 'z.
"
" Although the comments indicate the maps use a leading backslash,
" actually they use <Leader> (:he mapleader), so the user can
" specify that the maps start how he or she prefers.
"
" Note: these maps all use <Align.vim>.
"
" Romans 1:20 For the invisible things of Him since the creation of the {{{1
" world are clearly seen, being perceived through the things that are
" made, even His everlasting power and divinity; that they may be
" without excuse.

" ---------------------------------------------------------------------
" Load Once: {{{1
if &cp || exists("g:loaded_AlignMapsPlugin")
 finish
endif
let s:keepcpo                = &cpo
let g:loaded_AlignMapsPlugin = "v41"
set cpo&vim

" =====================================================================
"  Maps: {{{1

" ---------------------------------------------------------------------
" WS: wrapper start map (internal)  {{{2
" Produces a blank line above and below, marks with 'y and 'z
if !hasmapto('<Plug>WrapperStart')
 map <unique> <SID>WS	<Plug>AlignMapsWrapperStart
endif
nmap <silent> <script> <Plug>AlignMapsWrapperStart	:set lz<CR>:call AlignMaps#WrapperStart(0)<CR>
vmap <silent> <script> <Plug>AlignMapsWrapperStart	:<c-u>set lz<CR>:call AlignMaps#WrapperStart(1)<CR>

" ---------------------------------------------------------------------
" WE: wrapper end (internal)   {{{2
" Removes guard lines, restores marks y and z, and restores search pattern
if !hasmapto('<Plug>WrapperEnd')
 nmap <unique> <SID>WE	<Plug>AlignMapsWrapperEnd
endif
nmap <silent> <script> <Plug>AlignMapsWrapperEnd	:call AlignMaps#WrapperEnd()<CR>:set nolz<CR>

" ---------------------------------------------------------------------
" Complex C-code alignment maps: {{{2
if !hasmapto('<Plug>AM_a?')   |map <unique> <Leader>a?		<Plug>AM_a?|endif
if !hasmapto('<Plug>AM_a,')   |map <unique> <Leader>a,		<Plug>AM_a,|endif
if !hasmapto('<Plug>AM_a<')   |map <unique> <Leader>a<		<Plug>AM_a<|endif
if !hasmapto('<Plug>AM_a=')   |map <unique> <Leader>a=		<Plug>AM_a=|endif
if !hasmapto('<Plug>AM_a(')   |map <unique> <Leader>a(		<Plug>AM_a(|endif
if !hasmapto('<Plug>AM_abox') |map <unique> <Leader>abox	<Plug>AM_abox|endif
if !hasmapto('<Plug>AM_acom') |map <unique> <Leader>acom	<Plug>AM_acom|endif
if !hasmapto('<Plug>AM_adcom')|map <unique> <Leader>adcom	<Plug>AM_adcom|endif
if !hasmapto('<Plug>AM_aocom')|map <unique> <Leader>aocom	<Plug>AM_aocom|endif
if !hasmapto('<Plug>AM_ascom')|map <unique> <Leader>ascom	<Plug>AM_ascom|endif
if !hasmapto('<Plug>AM_adec') |map <unique> <Leader>adec	<Plug>AM_adec|endif
if !hasmapto('<Plug>AM_adef') |map <unique> <Leader>adef	<Plug>AM_adef|endif
if !hasmapto('<Plug>AM_afnc') |map <unique> <Leader>afnc	<Plug>AM_afnc|endif
if !hasmapto('<Plug>AM_afnc') |map <unique> <Leader>afnc	<Plug>AM_afnc|endif
if !hasmapto('<Plug>AM_aunum')|map <unique> <Leader>aunum	<Plug>AM_aenum|endif
if !hasmapto('<Plug>AM_aenum')|map <unique> <Leader>aenum	<Plug>AM_aunum|endif
if exists("g:alignmaps_euronumber") && !exists("g:alignmaps_usanumber")
 if !hasmapto('<Plug>AM_anum')|map <unique> <Leader>anum	<Plug>AM_aenum|endif
else
 if !hasmapto('<Plug>AM_anum')|map <unique> <Leader>anum	<Plug>AM_aunum|endif
endif

map <silent> <script> <Plug>AM_a?		<SID>WS:AlignCtrl mIp1P1lC ? : : : : <CR>:'a,.Align<CR>:'a,'z-1s/\(\s\+\)? /?\1/e<CR><SID>WE
map <silent> <script> <Plug>AM_a,		<SID>WS:'y,'zs/\(\S\)\s\+/\1 /ge<CR>'yjma'zk:call AlignMaps#CharJoiner(",")<cr>:silent 'y,'zg/,/call AlignMaps#FixMultiDec()<CR>'z:exe "norm \<Plug>AM_adec"<cr><SID>WE
map <silent> <script> <Plug>AM_a<		<SID>WS:AlignCtrl mIp1P1=l << >><CR>:'a,.Align<CR><SID>WE
map <silent> <script> <Plug>AM_a(       <SID>WS:AlignCtrl mIp0P1=l<CR>:'a,.Align [(,]<CR>:sil 'y+1,'z-1s/\(\s\+\),/,\1/ge<CR><SID>WE
map <silent> <script> <Plug>AM_a=		<SID>WS:AlignCtrl mIp1P1=l<CR>:AlignCtrl g :=<CR>:'a,'zAlign :\==<CR><SID>WE
map <silent> <script> <Plug>AM_abox		<SID>WS:let g:alignmaps_iws=substitute(getline("'a"),'^\(\s*\).*$','\1','e')<CR>:'a,'z-1s/^\s\+//e<CR>:'a,'z-1s/^.*$/@&@/<CR>:AlignCtrl m=p01P0w @<CR>:'a,.Align<CR>:'a,'z-1s/@/ * /<CR>:'a,'z-1s/@$/*/<CR>'aYP:s/./*/g<CR>0r/'zkYp:s/./*/g<CR>0r A/<Esc>:exe "'a-1,'z-1s/^/".g:alignmaps_iws."/e"<CR><SID>WE
map <silent> <script> <Plug>AM_acom		<SID>WS:'a,.s/\/[*/]\/\=/@&@/e<CR>:'a,.s/\*\//@&/e<CR>:'y,'zs/^\( *\) @/\1@/e<CR>'zk:call AlignMaps#StdAlign(2)<CR>:'y,'zs/^\(\s*\) @/\1/e<CR>:'y,'zs/ @//eg<CR><SID>WE
map <silent> <script> <Plug>AM_adcom	<SID>WS:'a,.v/^\s*\/[/*]/s/\/[*/]\*\=/@&@/e<CR>:'a,.v/^\s*\/[/*]/s/\*\//@&/e<CR>:'y,'zv/^\s*\/[/*]/s/^\( *\) @/\1@/e<CR>'zk:call AlignMaps#StdAlign(3)<cr>:'y,'zv/^\s*\/[/*]/s/^\(\s*\) @/\1/e<CR>:'y,'zs/ @//eg<CR><SID>WE
map <silent> <script> <Plug>AM_aocom	<SID>WS:AlignPush<CR>:AlignCtrl g /[*/]<CR>:exe "norm \<Plug>AM_acom"<cr>:AlignPop<CR><SID>WE
map <silent> <script> <Plug>AM_ascom	<SID>WS:'a,.s/\/[*/]/@&@/e<CR>:'a,.s/\*\//@&/e<CR>:silent! 'a,.g/^\s*@\/[*/]/s/@//ge<CR>:AlignCtrl v ^\s*\/[*/]<CR>:AlignCtrl g \/[*/]<CR>'zk:call AlignMaps#StdAlign(2)<cr>:'y,'zs/^\(\s*\) @/\1/e<CR>:'y,'zs/ @//eg<CR><SID>WE
map <silent> <script> <Plug>AM_adec		<SID>WS:'a,'zs/\([^ \t/(]\)\([*&]\)/\1 \2/e<CR>:'y,'zv/^\//s/\([^ \t]\)\s\+/\1 /ge<CR>:'y,'zv/^\s*[*/]/s/\([^/][*&]\)\s\+/\1/ge<CR>:'y,'zv/^\s*[*/]/s/^\(\s*\%(\K\k*\s\+\%([a-zA-Z_*(&]\)\@=\)\+\)\([*(&]*\)\s*\([a-zA-Z0-9_()]\+\)\s*\(\(\[.\{-}]\)*\)\s*\(=\)\=\s*\(.\{-}\)\=\s*;/\1@\2#@\3\4@\6@\7;@/e<CR>:'y,'zv/^\s*[*/]/s/\*\/\s*$/@*\//e<CR>:'y,'zv/^\s*[*/]/s/^\s\+\*/@@@@@* /e<CR>:'y,'zv/^\s*[*/]/s/^@@@@@\*\(.*[^*/]\)$/&@*/e<CR>'yjma'zk:AlignCtrl v ^\s*[*/#]<CR>:call AlignMaps#StdAlign(1)<cr>:'y,'zv/^\s*[*/]/s/@ //ge<CR>:'y,'zv/^\s*[*/]/s/\(\s*\);/;\1/e<CR>:'y,'zv/^#/s/# //e<CR>:'y,'zv/^\s\+[*/#]/s/\([^/*]\)\(\*\+\)\( \+\)/\1\3\2/e<CR>:'y,'zv/^\s\+[*/#]/s/\((\+\)\( \+\)\*/\2\1*/e<CR>:'y,'zv/^\s\+[*/#]/s/^\(\s\+\) \*/\1*/e<CR>:'y,'zv/^\s\+[*/#]/s/[ \t@]*$//e<CR>:'y,'zs/^[*]/ */e<CR><SID>WE
map <silent> <script> <Plug>AM_adef		<SID>WS:AlignPush<CR>:AlignCtrl v ^\s*\(\/\*\<bar>\/\/\)<CR>:'a,.v/^\s*\(\/\*\<bar>\/\/\)/s/^\(\s*\)#\(\s\)*define\s*\(\I[a-zA-Z_0-9(),]*\)\s*\(.\{-}\)\($\<Bar>\/\*\)/#\1\2define @\3@\4@\5/e<CR>:'a,.v/^\s*\(\/\*\<bar>\/\/\)/s/\($\<Bar>\*\/\)/@&/e<CR>'zk:call AlignMaps#StdAlign(1)<cr>'yjma'zk:'a,.v/^\s*\(\/\*\<bar>\/\/\)/s/ @//g<CR><SID>WE
map <silent> <script> <Plug>AM_afnc		:<c-u>set lz<CR>:silent call AlignMaps#Afnc()<CR>:set nolz<CR>
map <silent> <script> <Plug>AM_aunum	<SID>WS:'a,'zs/\%([0-9.]\)\s\+\zs\([-+.]\=\d\)/@\1/ge<CR>:'a,'zs/\(\(^\|\s\)\d\+\)\(\s\+\)@/\1@\3@/ge<CR>:'a,'zs/\.@/\.0@/ge<CR>:AlignCtrl wmp0P0r<CR>:'a,'zAlign [.@]<CR>:'a,'zs/@/ /ge<CR>:'a,'zs/\(\.\)\(\s\+\)\([0-9.,eE+]\+\)/\1\3\2/ge<CR>:'a,'zs/\([eE]\)\(\s\+\)\([0-9+\-+]\+\)/\1\3\2/ge<CR><SID>WE
map <silent> <script> <Plug>AM_aenum	<SID>WS:'a,'zs/\%([0-9.]\)\s\+\([-+]\=\d\)/\1@\2/ge<CR>:'a,'zs/\.@/\.0@/ge<CR>:AlignCtrl wmp0P0r<CR>:'a,'zAlign [,@]<CR>:'a,'zs/@/ /ge<CR>:'a,'zs/\(,\)\(\s\+\)\([-0-9.,eE+]\+\)/\1\3\2/ge<CR>:'a,'zs/\([eE]\)\(\s\+\)\([0-9+\-+]\+\)/\1\3\2/ge<CR><SID>WE

" ---------------------------------------------------------------------
" html table alignment	{{{2
if !hasmapto('<Plug>AM_Htd')|map <unique> <Leader>Htd	<Plug>AM_Htd|endif
map <silent> <script> <Plug>AM_Htd <SID>WS:'y,'zs%<[tT][rR]><[tT][dD][^>]\{-}>\<Bar></[tT][dD]><[tT][dD][^>]\{-}>\<Bar></[tT][dD]></[tT][rR]>%@&@%g<CR>'yjma'zk:AlignCtrl m=Ilp1P0 @<CR>:'a,.Align<CR>:'y,'zs/ @/@/<CR>:'y,'zs/@ <[tT][rR]>/<[tT][rR]>/ge<CR>:'y,'zs/@//ge<CR><SID>WE

" ---------------------------------------------------------------------
" character-based right-justified alignment maps {{{2
if !hasmapto('<Plug>AM_T|')|map <unique> <Leader>T|		<Plug>AM_T||endif
if !hasmapto('<Plug>AM_T#')	 |map <unique> <Leader>T#		<Plug>AM_T#|endif
if !hasmapto('<Plug>AM_T,')	 |map <unique> <Leader>T,		<Plug>AM_T,o|endif
if !hasmapto('<Plug>AM_Ts,') |map <unique> <Leader>Ts,		<Plug>AM_Ts,|endif
if !hasmapto('<Plug>AM_T:')	 |map <unique> <Leader>T:		<Plug>AM_T:|endif
if !hasmapto('<Plug>AM_T;')	 |map <unique> <Leader>T;		<Plug>AM_T;|endif
if !hasmapto('<Plug>AM_T<')	 |map <unique> <Leader>T<		<Plug>AM_T<|endif
if !hasmapto('<Plug>AM_T=')	 |map <unique> <Leader>T=		<Plug>AM_T=|endif
if !hasmapto('<Plug>AM_T?')	 |map <unique> <Leader>T?		<Plug>AM_T?|endif
if !hasmapto('<Plug>AM_T@')	 |map <unique> <Leader>T@		<Plug>AM_T@|endif
if !hasmapto('<Plug>AM_Tab') |map <unique> <Leader>Tab		<Plug>AM_Tab|endif
if !hasmapto('<Plug>AM_Tsp') |map <unique> <Leader>Tsp		<Plug>AM_Tsp|endif
if !hasmapto('<Plug>AM_T~')	 |map <unique> <Leader>T~		<Plug>AM_T~|endif

map <silent> <script> <Plug>AM_T| <SID>WS:AlignCtrl mIp0P0=r <Bar><CR>:'a,.Align<CR><SID>WE
map <silent> <script> <Plug>AM_T#   <SID>WS:AlignCtrl mIp0P0=r #<CR>:'a,.Align<CR><SID>WE
map <silent> <script> <Plug>AM_T,   <SID>WS:AlignCtrl mIp0P1=r ,<CR>:'a,.Align<CR><SID>WE
map <silent> <script> <Plug>AM_Ts,  <SID>WS:AlignCtrl mIp0P1=r ,<CR>:'a,.Align<CR>:'a,.s/\(\s*\),/,\1/ge<CR><SID>WE
map <silent> <script> <Plug>AM_T:   <SID>WS:AlignCtrl mIp1P1=r :<CR>:'a,.Align<CR><SID>WE
map <silent> <script> <Plug>AM_T;   <SID>WS:AlignCtrl mIp0P0=r ;<CR>:'a,.Align<CR><SID>WE
map <silent> <script> <Plug>AM_T<   <SID>WS:AlignCtrl mIp0P0=r <<CR>:'a,.Align<CR><SID>WE
map <silent> <script> <Plug>AM_T=   <SID>WS:'a,'z-1s/\s\+\([*/+\-%<Bar>&\~^]\==\)/ \1/e<CR>:'a,'z-1s@ \+\([*/+\-%<Bar>&\~^]\)=@\1=@ge<CR>:'a,'z-1s/; */;@/e<CR>:'a,'z-1s/==/\="\<Char-0x0f>\<Char-0x0f>"/ge<CR>:'a,'z-1s/!=/\x="!\<Char-0x0f>"/ge<CR>:AlignCtrl mIp1P1=r = @<CR>:AlignCtrl g =<CR>:'a,'z-1Align<CR>:'a,'z-1s/; *@/;/e<CR>:'a,'z-1s/; *$/;/e<CR>:'a,'z-1s@\([*/+\-%<Bar>&\~^]\)\( \+\)=@\2\1=@ge<CR>:'a,'z-1s/\( \+\);/;\1/ge<CR>:'a,'z-1s/\xff/=/ge<CR><SID>WE:exe "norm <Plug>acom"
map <silent> <script> <Plug>AM_T?   <SID>WS:AlignCtrl mIp0P0=r ?<CR>:'a,.Align<CR>:'y,'zs/ \( *\);/;\1/ge<CR><SID>WE
map <silent> <script> <Plug>AM_T@   <SID>WS:AlignCtrl mIp0P0=r @<CR>:'a,.Align<CR><SID>WE
map <silent> <script> <Plug>AM_Tab  <SID>WS:'a,.s/^\(\t*\)\(.*\)/\=submatch(1).escape(substitute(submatch(2),'\t','@','g'),'\')/<CR>:AlignCtrl mI=r @<CR>:'a,.Align<CR>:'y+1,'z-1s/@/ /g<CR><SID>WE
map <silent> <script> <Plug>AM_Tsp  <SID>WS:'a,.s/^\(\s*\)\(.*\)/\=submatch(1).escape(substitute(submatch(2),'\s\+','@','g'),'\')/<CR>:AlignCtrl mI=r @<CR>:'a,.Align<CR>:'y+1,'z-1s/@/ /g<CR><SID>WE
map <silent> <script> <Plug>AM_T~   <SID>WS:AlignCtrl mIp0P0=r ~<CR>:'a,.Align<CR>:'y,'zs/ \( *\);/;\1/ge<CR><SID>WE

" ---------------------------------------------------------------------
" character-based left-justified alignment maps {{{2
if !hasmapto('<Plug>AM_t|')	|map <unique> <Leader>t|	<Plug>AM_t||endif
if !hasmapto('<Plug>AM_t#')		|map <unique> <Leader>t#	<Plug>AM_t#|endif
if !hasmapto('<Plug>AM_t,')		|map <unique> <Leader>t,	<Plug>AM_t,|endif
if !hasmapto('<Plug>AM_t:')		|map <unique> <Leader>t:	<Plug>AM_t:|endif
if !hasmapto('<Plug>AM_t;')		|map <unique> <Leader>t;	<Plug>AM_t;|endif
if !hasmapto('<Plug>AM_t<')		|map <unique> <Leader>t<	<Plug>AM_t<|endif
if !hasmapto('<Plug>AM_t=')		|map <unique> <Leader>t=	<Plug>AM_t=|endif
if !hasmapto('<Plug>AM_ts,')	|map <unique> <Leader>ts,	<Plug>AM_ts,|endif
if !hasmapto('<Plug>AM_ts:')	|map <unique> <Leader>ts:	<Plug>AM_ts:|endif
if !hasmapto('<Plug>AM_ts;')	|map <unique> <Leader>ts;	<Plug>AM_ts;|endif
if !hasmapto('<Plug>AM_ts<')	|map <unique> <Leader>ts<	<Plug>AM_ts<|endif
if !hasmapto('<Plug>AM_ts=')	|map <unique> <Leader>ts=	<Plug>AM_ts=|endif
if !hasmapto('<Plug>AM_w=')		|map <unique> <Leader>w=	<Plug>AM_w=|endif
if !hasmapto('<Plug>AM_t?')		|map <unique> <Leader>t?	<Plug>AM_t?|endif
if !hasmapto('<Plug>AM_t~')		|map <unique> <Leader>t~	<Plug>AM_t~|endif
if !hasmapto('<Plug>AM_t@')		|map <unique> <Leader>t@	<Plug>AM_t@|endif
if !hasmapto('<Plug>AM_m=')		|map <unique> <Leader>m=	<Plug>AM_m=|endif
if !hasmapto('<Plug>AM_tab')	|map <unique> <Leader>tab	<Plug>AM_tab|endif
if !hasmapto('<Plug>AM_tml')	|map <unique> <Leader>tml	<Plug>AM_tml|endif
if !hasmapto('<Plug>AM_tsp')	|map <unique> <Leader>tsp	<Plug>AM_tsp|endif
if !hasmapto('<Plug>AM_tsq')	|map <unique> <Leader>tsq	<Plug>AM_tsq|endif
if !hasmapto('<Plug>AM_tt')		|map <unique> <Leader>tt	<Plug>AM_tt|endif

map <silent> <script> <Plug>AM_t|		<SID>WS:AlignCtrl mIp0P0=l <Bar><CR>:'a,.Align<CR><SID>WE
map <silent> <script> <Plug>AM_t#		<SID>WS:AlignCtrl mIp0P0=l #<CR>:'a,.Align<CR><SID>WE
map <silent> <script> <Plug>AM_t,		<SID>WS:AlignCtrl mIp0P1=l ,<CR>:'a,.Align<CR><SID>WE
map <silent> <script> <Plug>AM_t:		<SID>WS:AlignCtrl mIp1P1=l :<CR>:'a,.Align<CR><SID>WE
map <silent> <script> <Plug>AM_t;		<SID>WS:AlignCtrl mIp0P1=l ;<CR>:'a,.Align<CR>:sil 'y,'zs/\( *\);/;\1/ge<CR><SID>WE
map <silent> <script> <Plug>AM_t<		<SID>WS:AlignCtrl mIp0P0=l <<CR>:'a,.Align<CR><SID>WE
map <silent> <script> <Plug>AM_t=		<SID>WS:call AlignMaps#Equals()<CR><SID>WE
map <silent> <script> <Plug>AM_ts,		<SID>WS:AlignCtrl mIp0P1=l #<CR>:'a,.Align<CR>:sil 'y+1,'z-1s/\(\s*\)#/,\1/ge<CR><SID>WE
map <silent> <script> <Plug>AM_ts,		<SID>WS:AlignCtrl mIp0P1=l ,<CR>:'a,.Align<CR>:sil 'y+1,'z-1s/\(\s*\),/,\1/ge<CR><SID>WE
map <silent> <script> <Plug>AM_ts:		<SID>WS:AlignCtrl mIp1P1=l :<CR>:'a,.Align<CR>:sil 'y+1,'z-1s/\(\s*\):/:\1/ge<CR><SID>WE
map <silent> <script> <Plug>AM_ts;		<SID>WS:AlignCtrl mIp1P1=l ;<CR>:'a,.Align<CR>:sil 'y+1,'z-1s/\(\s*\);/;\1/ge<CR><SID>WE
map <silent> <script> <Plug>AM_ts<		<SID>WS:AlignCtrl mIp1P1=l <<CR>:'a,.Align<CR>:sil 'y+1,'z-1s/\(\s*\)</<\1/ge<CR><SID>WE
map <silent> <script> <Plug>AM_ts=		<SID>WS:AlignCtrl mIp1P1=l =<CR>:'a,.Align<CR>:sil 'y+1,'z-1s/\(\s*\)=/=\1/ge<CR><SID>WE
map <silent> <script> <Plug>AM_w=		<SID>WS:'a,'zg/=/s/\s\+\([*/+\-%<Bar>&\~^]\==\)/ \1/e<CR>:'a,'zg/=/s@ \+\([*/+\-%<Bar>&\~^]\)=@\1=@ge<CR>:'a,'zg/=/s/==/\="\<Char-0x0f>\<Char-0x0f>"/ge<CR>:'a,'zg/=/s/!=/\="!\<Char-0x0f>"/ge<CR>'zk:AlignCtrl mWp1P1=l =<CR>:AlignCtrl g =<CR>:'a,'z-1g/=/Align<CR>:'a,'z-1g/=/s@\([*/+\-%<Bar>&\~^!=]\)\( \+\)=@\2\1=@ge<CR>:'a,'z-1g/=/s/\( \+\);/;\1/ge<CR>:'a,'z-1v/^\s*\/[*/]/s/\/[*/]/@&@/e<CR>:'a,'z-1v/^\s*\/[*/]/s/\*\//@&/e<CR>'zk:call AlignMaps#StdAlign(1)<cr>:'y,'zs/^\(\s*\) @/\1/e<CR>:'a,'z-1g/=/s/\xff/=/ge<CR>:'y,'zg/=/s/ @//eg<CR><SID>WE
map <silent> <script> <Plug>AM_t?		<SID>WS:AlignCtrl mIp0P0=l ?<CR>:'a,.Align<CR>:.,'zs/ \( *\);/;\1/ge<CR><SID>WE
map <silent> <script> <Plug>AM_t~		<SID>WS:AlignCtrl mIp0P0=l ~<CR>:'a,.Align<CR>:'y,'zs/ \( *\);/;\1/ge<CR><SID>WE
map <silent> <script> <Plug>AM_t@		<SID>WS::call AlignMaps#StdAlign(1)<cr>:<SID>WE
map <silent> <script> <Plug>AM_m=		<SID>WS:'a,'zs/\s\+\([*/+\-%<Bar>&\~^]\==\)/ \1/e<CR>:'a,'zs@ \+\([*/+\-%<Bar>&\~^]\)=@\1=@ge<CR>:'a,'zs/==/\="\<Char-0x0f>\<Char-0x0f>"/ge<CR>:'a,'zs/!=/\="!\<Char-0x0f>"/ge<CR>'zk:AlignCtrl mIp1P1=l =<CR>:AlignCtrl g =<CR>:'a,'z-1Align<CR>:'a,'z-1s@\([*/+\-%<Bar>&\~^!=]\)\( \+\)=@\2\1=@ge<CR>:'a,'z-1s/\( \+\);/;\1/ge<CR>:'a,'z-s/%\ze[^=]/ @%@ /e<CR>'zk:call AlignMaps#StdAlign(1)<cr>:'y,'zs/^\(\s*\) @/\1/e<CR>:'a,'z-1s/\xff/=/ge<CR>:'y,'zs/ @//eg<CR><SID>WE
map <silent> <script> <Plug>AM_tab		<SID>WS:'a,.s/^\(\t*\)\(.*\)$/\=submatch(1).escape(substitute(submatch(2),'\t',"\<Char-0x0f>",'g'),'\')/<CR>:if &ts == 1<bar>exe "AlignCtrl mI=lp0P0 \<Char-0x0f>"<bar>else<bar>exe "AlignCtrl mI=l \<Char-0x0f>"<bar>endif<CR>:'a,.Align<CR>:exe "'y+1,'z-1s/\<Char-0x0f>/".((&ts == 1)? '\t' : ' ')."/g"<CR><SID>WE
map <silent> <script> <Plug>AM_tml		<SID>WS:AlignCtrl mWp1P0=l \\\@<!\\\s*$<CR>:'a,.Align<CR><SID>WE
map <silent> <script> <Plug>AM_tsp		<SID>WS:'a,.s/^\(\s*\)\(.*\)/\=submatch(1).escape(substitute(submatch(2),'\s\+','@','g'),'\')/<CR>:AlignCtrl mI=lp0P0 @<CR>:'a,.Align<CR>:'y+1,'z-1s/@/ /g<CR><SID>WE
map <silent> <script> <Plug>AM_tsq		<SID>WS:'a,.AlignReplaceQuotedSpaces<CR>:'a,.s/^\(\s*\)\(.*\)/\=submatch(1).substitute(submatch(2),'\s\+','@','g')/<CR>:AlignCtrl mIp0P0=l @<CR>:'a,.Align<CR>:'y+1,'z-1s/[%@]/ /g<CR><SID>WE
map <silent> <script> <Plug>AM_tt		<SID>WS:AlignCtrl mIp1P1=l \\\@<!& \\\\<CR>:'a,.Align<CR><SID>WE

" =====================================================================
" Menu Support: {{{1
"   ma ..move.. use menu
"   v V or ctrl-v ..move.. use menu
if has("menu") && has("gui_running") && &go =~ 'm' && !exists("s:firstmenu")
 let s:firstmenu= 1
 if !exists("g:DrChipTopLvlMenu")
  let g:DrChipTopLvlMenu= "DrChip."
 endif
 if g:DrChipTopLvlMenu != ""
  let s:mapleader = exists("g:mapleader")? g:mapleader : '\'
  let s:emapleader= escape(s:mapleader,'\ ')
  exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.<<\ and\ >><tab>'.s:emapleader.'a<	'.s:mapleader.'a<'
  exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Assignment\ =<tab>'.s:emapleader.'t=	'.s:mapleader.'t='
  exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Assignment\ :=<tab>'.s:emapleader.'a=	'.s:mapleader.'a='
  exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Backslashes<tab>'.s:emapleader.'tml	'.s:mapleader.'tml'
  exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Breakup\ Comma\ Declarations<tab>'.s:emapleader.'a,	'.s:mapleader.'a,'
  exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.C\ Comment\ Box<tab>'.s:emapleader.'abox	'.s:mapleader.'abox'
  exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Commas<tab>'.s:emapleader.'t,	'.s:mapleader.'t,'
  exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Commas<tab>'.s:emapleader.'ts,	'.s:mapleader.'ts,'
  exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Commas\ With\ Strings<tab>'.s:emapleader.'tsq	'.s:mapleader.'tsq'
  exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Comments<tab>'.s:emapleader.'acom	'.s:mapleader.'acom'
  exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Comments\ Only<tab>'.s:emapleader.'aocom	'.s:mapleader.'aocom'
  exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Declaration\ Comments<tab>'.s:emapleader.'adcom	'.s:mapleader.'adcom'
  exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Declarations<tab>'.s:emapleader.'adec	'.s:mapleader.'adec'
  exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Definitions<tab>'.s:emapleader.'adef	'.s:mapleader.'adef'
  exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Function\ Header<tab>'.s:emapleader.'afnc	'.s:mapleader.'afnc'
  exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Html\ Tables<tab>'.s:emapleader.'Htd	'.s:mapleader.'Htd'
  exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.(\.\.\.)?\.\.\.\ :\ \.\.\.<tab>'.s:emapleader.'a?	'.s:mapleader.'a?'
  exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Numbers<tab>'.s:emapleader.'anum	'.s:mapleader.'anum'
  exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Numbers\ (American-Style)<tab>'.s:emapleader.'aunum	<Leader>aunum	'.s:mapleader.'aunum	<Leader>aunum'
  exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Numbers\ (Euro-Style)<tab>'.s:emapleader.'aenum	'.s:mapleader.'aenum'
  exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Spaces\ (Left\ Justified)<tab>'.s:emapleader.'tsp	'.s:mapleader.'tsp'
  exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Spaces\ (Right\ Justified)<tab>'.s:emapleader.'Tsp	'.s:mapleader.'Tsp'
  exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Statements\ With\ Percent\ Style\ Comments<tab>'.s:emapleader.'m=	'.s:mapleader.'m='
  exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Symbol\ <<tab>'.s:emapleader.'t<	'.s:mapleader.'t<'
  exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Symbol\ \|<tab>'.s:emapleader.'t\|	'.s:mapleader.'t|'
  exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Symbol\ @<tab>'.s:emapleader.'t@	'.s:mapleader.'t@'
  exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Symbol\ #<tab>'.s:emapleader.'t#	'.s:mapleader.'t#'
  exe 'menu '.g:DrChipTopLvlMenu.'AlignMaps.Tabs<tab>'.s:emapleader.'tab	'.s:mapleader.'tab'
  unlet s:mapleader
  unlet s:emapleader
 endif
endif

" =====================================================================
"  Restore: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo

" ==============================================================================
"  Modelines: {{{1
" vim: ts=4 nowrap fdm=marker
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

