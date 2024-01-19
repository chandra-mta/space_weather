PRO MTA_CHECK_XMM

;xmm_7d_archive='xmm_7day.archive2'
;readcol,xmm_7d_archive, $ 
;  time_sec,le0,le1,le2, $
;  hes0,hes1,hes2,hec, $
;  format='F,F,F,F,F,F,F,F'
;  format='A,F,F,F,F,F,F,F'

; read current data
xmm_7d_current='radmon_02h_curr.dat'
readcol,xmm_7d_current, $ 
  time_stamp,le0,le1,le2,hes0,hes1,hes2,hec, $
  format='A,F,F,F,F,F,F,F'
time_sec=xmm_time(time_stamp)

tlefile="/proj/rac/ops/ephem/TLE/xmm.spctrk"
readcol,tlefile,sec,yy,dd,hh,mm,ss,x_eci,y_eci,z_eci,vx,vy,vz, $
  format='L,I,I,I,I,I,F,F,F,F,F,F',skipline=5
sec=sec-8.83613e+08-86400.0
time=(sec/60./60./24.)-2191.0

r_eci=sqrt(x_eci^2+y_eci^2+z_eci^2)/1000.0

le1_t_last=time_sec(0)
le2_t_last=time_sec(0)
le1_count=0
le2_count=0
for i=0,n_elements(time_sec)-1 do begin
  diff=abs(time_sec(i)-time)
  b=where(diff eq min(diff))
  if (le1(i) gt 80.0 and r_eci(b(0)) gt 60) then begin
    t1_diff=time_sec(i)-le1_t_last
    print,t1_diff
    if (t1_diff lt 30) then le1_count=le1_count+1
    if (t1_diff ge 30) then le1_count=0
    le1_t_last=time_sec(i)
  endif ;if (le1 gt 80.0 and r_eci(b(0)) gt 60) then begin
  if (le2(i) gt 30.0 and r_eci(b(0)) gt 60) then begin
    t2_diff=time_sec(i)-le2_t_last
    if (t2_diff lt 30) then le2_count=le2_count+1
    if (t2_diff ge 30) then le2_count=0
    le2_t_last=time_sec(i)
  endif ;if (le2 gt 30.0 and r_eci(b(0)) gt 60) then begin
endfor ;for i=0,n_elements(time_stamp_arc)-1 do begin

print,max(le1)
print, cxtime(le1_t_last,'sec','cal'),le1_count,"le1"
print, cxtime(le2_t_last,'sec','cal'),le2_count,"le2"

end
