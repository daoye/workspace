let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/newegg/ngm-site-ssl
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
if &shortmess =~ 'A'
  set shortmess=aoOA
else
  set shortmess=aoO
endif
badd +22 src/modules/order/pages/order-detail/components/orderDetailOrderInfo.tsx
badd +220 src/modules/order/shared-components/updatePayment.tsx
badd +97 src/modules/order/pages/order-detail/components/orderDetail.tsx
badd +130 src/modules/order/pages/order-history/components/orderList.tsx
badd +51 src/modules/order/states/updateOrder.state.ts
badd +41 ngm-packages/packages/common/src/types/models/orderReview.model.ts
badd +2 ngm-packages/packages/common/src/types/index.ts
badd +2 ngm-packages/packages/common/src/types/models/index.ts
badd +74 src/modules/shoppingflow/pages/checkout/components/checkout.tsx
argglobal
%argdel
edit src/modules/order/shared-components/updatePayment.tsx
argglobal
balt src/modules/shoppingflow/pages/checkout/components/checkout.tsx
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=99
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
6,8fold
1,30fold
32,34fold
41,46fold
50,52fold
55,57fold
49,58fold
62,64fold
65,66fold
61,67fold
70,75fold
82,83fold
86,87fold
84,88fold
78,94fold
97,98fold
103,109fold
101,111fold
114,116fold
124,128fold
132,135fold
141,143fold
140,146fold
139,146fold
154,175fold
131,175fold
119,176fold
180,181fold
179,186fold
190,191fold
198,199fold
202,204fold
189,207fold
211,220fold
229,232fold
239,241fold
244,246fold
248,250fold
252,254fold
256,258fold
242,259fold
265,266fold
270,272fold
268,273fold
280,282fold
279,283fold
277,284fold
276,285fold
287,289fold
286,290fold
275,291fold
274,292fold
298,299fold
296,301fold
294,303fold
305,307fold
304,308fold
293,309fold
264,310fold
263,311fold
261,312fold
260,313fold
238,314fold
317,319fold
316,320fold
325,326fold
323,328fold
322,329fold
333,335fold
331,337fold
330,338fold
341,344fold
340,345fold
352,355fold
357,362fold
366,368fold
365,368fold
372,374fold
378,385fold
391,392fold
390,394fold
398,401fold
396,402fold
404,406fold
403,411fold
395,412fold
389,413fold
428,429fold
416,429fold
415,431fold
414,432fold
435,437fold
434,437fold
433,441fold
388,442fold
371,443fold
364,444fold
363,445fold
350,445fold
348,447fold
347,448fold
237,450fold
236,451fold
455,457fold
454,458fold
453,459fold
461,463fold
228,465fold
476,478fold
470,478fold
498,499fold
484,499fold
504,509fold
513,515fold
227,517fold
226,518fold
210,518fold
37,519fold
522,524fold
521,525fold
let &fdl = &fdl
let s:l = 217 - ((20 * winheight(0) + 18) / 37)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 217
normal! 021|
tabnext 1
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0 && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20
let &shortmess = s:shortmess_save
let s:sx = expand("<sfile>:p:r")."x.vim"
if filereadable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &g:so = s:so_save | let &g:siso = s:siso_save
set hlsearch
nohlsearch
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
