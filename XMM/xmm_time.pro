FUNCTION XMM_TIME, time_str
; 20. Jul 2003 BDS
; given string arr of xmm_rad time format 'yyyy-doy-dd-hh:mm:ss'
; convert to seconds since Jan 1, 1998

; convert/reformat time
nel=n_elements(time_str)
yr=fltarr(nel)
doy=fltarr(nel)
hh=fltarr(nel)
mm=fltarr(nel)
ss=fltarr(nel)
jday=fltarr(nel)
sec=lonarr(nel)
for i=0L,nel-1 do begin
  tmp1=strsplit(time_str(i),":",/extract)
  tmp2=strsplit(tmp1(0),"-",/extract)
  yr(i)=tmp2(0)
  doy(i)=tmp2(1)
  hh(i)=tmp2(2)
  tmp1=strsplit(time_str(i),"-",/extract)
  tmp2=strsplit(tmp1(2),":",/extract)
  mm(i)=tmp2(1)
  ss(i)=tmp2(2)
endfor ; for i=0L,nel-1 do begin
jday=((yr-2000.)*365.)+doy+(hh/24.)+(mm/60./24.)+(ss/60./60./24.)
sec=((yr-1998.)*365.*86400.)+((doy-1)*86400)+(hh*3600.)+(mm*60.)+ss
leap=2000
while (max(yr) gt leap) do begin
  b=where(yr gt leap,bnum)
  if (bnum gt 0) then begin
    jday(b)=jday(b)+1
    sec(b)=sec(b)+86400.0
  endif
  leap=leap+4
endwhile ; while (max(yr) gt leap) do begin
;print,"jday ",jday," jday" ;debugtime

return,sec
end
