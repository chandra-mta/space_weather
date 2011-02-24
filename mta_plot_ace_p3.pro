FUNCTION NO_AXIS_LABELS, axis, index, value
; suppress labelling axis
return, string(" ")
end

PRO MTA_PLOT_ACE_P3, PLOTX=plotx
; make our own ace plot like http://ftp2.sec.noaa.gov/ace/Epam_7d.gif
;  but drop P2, which is broke and replace P3 (also broke) with
;  a scaling from P6 and P7
; 04. Nov 2003 BDS
; 04. Feb 2004 BDS - just plot P3 and scaled P3's for comparison

; first check for license
;  this is dumb, just crashes before continuing if no license
if (NOT have_license()) then return

p5_p3_scale=7 ; p5 to p3 scale factor
p6_p3_scale=36 ; p5 to p3 scale factor
p7_p3_scale=110 ; p7 to p3 scale factor
t_arch=7 ; how many days to plot

ace_7d_archive='ace_7day.archive'
;rdfloat,ace_7d_archive, $ 
readcol,ace_7d_archive, $ 
  ;# UT Date   Time  Julian  of the  ----- Electron -----   
  ;# YR MO DA  HHMM    Day    Day    S    38-53   175-315   
  ;
  ;------------------- Protons keV -------------------   
  ;S   65-112   112-187   310-580   761-1220 060-1910   
  ;
  ;Anis. Interpol   Fluence
  ;Ratio   112-187   112-187
  yr,mo,da,hhmm,jday,sec,estat,de1,de4,pstat,p2,p3,p5,p6,p7,aindex,x1,x2, $
  skipline=16,format='F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F'
; and get most recent data
;rdfloat,'/proj/rac/ops/ACE/ace.archive', $ 
;readcol,'/proj/rac/ops/ACE/ace.archive', $ 
readcol,'ACE/ace.archive', $ 
  yr_r,mo_r,da_r,hhmm_r,jday_r,sec_r,estat_r,de1_r,de4_r, $
  pstat_r,p2_r,p3_r,p5_r,p6_r,p7_r,aindex_r,x1_r,x2_r, $
  skipline=16,format='F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F'

; use last45, if something is wrong with 3-day archive
spawn,"date '+%Z'",tz                                               ; jd_now
now=bin_date(systime())                                             ; jd_now
; make GMT                                                          ; jd_now
if (tz(0) eq "EST") then now(3)=now(3)+5                               ; jd_now
if (tz(0) eq "EDT") then now(3)=now(3)+4                               ; jd_now
; idl jd starts at noon, ace starts at 0Z                           ; jd_now
jd_now=julday(now(1),now(2),now(0),now(3)-12,now(4),now(5))-2400000 ; jd_now
time_r=long(jday_r)+(sec_r/86400.0)
now_diff=jd_now-max(time_r)
print,"ace.archive is ",now_diff*24.0*60.0," minutes old"  ;debug
if (now_diff gt 0.075) then begin ; close to 2 hrs w/ no new data
  call_brad, "check ace.archive"  ;debug
  print, "going to last45, check ace.archive"
  rdfloat,'last45', $ 
    yr_r,mo_r,da_r,hhmm_r,jday_r,sec_r,estat_r,de1_r,de4_r, $
    pstat_r,p2_r,p3_r,p5_r,p6_r,p7_r,aindex_r
  x1_r=replicate(-1000000,n_elements(yr_r))
  x2_r=replicate(-1000000,n_elements(yr_r))
endif ; if (jd_now-max(time_r) gt 0.075) then begin

; combine and sort data
yr=[ yr, yr_r]
mo=[ mo, mo_r]
da=[ da, da_r]
hhmm=[ hhmm, hhmm_r]
jday=[ jday, jday_r]
sec=[ sec, sec_r]
estat=[ estat, estat_r]
de1=[ de1, de1_r]
de4=[ de4, de4_r]
pstat=[ pstat, pstat_r]
p2=[ p2, p2_r]
p3=[ p3, p3_r]
p5=[ p5, p5_r]
p6=[ p6, p6_r]
p7=[ p7, p7_r]
aindex=[ aindex, aindex_r]
x1=[ x1, x1_r]
x2=[ x2, x2_r]
time=long(jday)+(sec/86400.0)
s=uniq(time,sort(time))
yr=yr(s)
mo=mo(s)
da=da(s)
hhmm=hhmm(s)
jday=jday(s)
sec=sec(s)
estat=estat(s)
de1=de1(s)
de4=de4(s)
pstat=pstat(s)
p2=p2(s)
p3=p3(s)
p5=p5(s)
p6=p6(s)
p7=p7(s)
aindex=aindex(s)
x1=x1(s)
x2=x2(s)
time=time(s)
; keep at least a 14 day archive
s_arch=t_arch
if (s_arch lt 14) then s_arch=14
b=where(jday ge max(jday)-s_arch+1,bnum)
if (bnum gt 0) then begin
  yr=yr(b)
  mo=mo(b)
  da=da(b)
  hhmm=hhmm(b)
  jday=jday(b)
  sec=sec(b)
  estat=estat(b)
  de1=de1(b)
  de4=de4(b)
  pstat=pstat(b)
  p2=p2(b)
  p3=p3(b)
  p5=p5(b)
  p6=p6(b)
  p7=p7(b)
  aindex=aindex(b)
  x1=x1(b)
  x2=x2(b)
  time=time(b)
endif ; if (bnum gt 0) then begin
; write updated t_arch-day archive
spawn,"head -16 "+ace_7d_archive+" > xace_7d_archive"
spawn,"mv xace_7d_archive "+ace_7d_archive
openu,aunit,ace_7d_archive,/get_lun,/append
for i=0,n_elements(yr)-2 do begin 
  ; don't print last one, it is usually -100000
  printf,aunit, $
    yr(i),mo(i),da(i),hhmm(i),jday(i),sec(i),estat(i),de1(i),de4(i), $
    pstat(i),p2(i),p3(i),p5(i),p6(i),p7(i),aindex(i),x1(i),x2(i), $
    format='(I4," ",I2," ",I2," ",I4," ",I6," ",I5," ", I1," ",2(E9.2," "), I1," ",5(E9.2," "),F6.3," ",E9.2," ",E9.2)'
endfor ;for i=0,n_elements(yr)-1 do begin
free_lun,aunit

p3s=p5*p5_p3_scale ; do scaling
p3a=p6*p6_p3_scale ; do scaling
p3b=p7*p7_p3_scale ; do scaling

; set-up plotting window
xwidth=640
yheight=540
if (keyword_set(plotx)) then begin
  set_plot,'x'
  window,0,xsize=xwidth,ysize=yheight
endif else begin
  set_plot,'z'
  device,set_resolution = [xwidth,yheight]
endelse ; 

;set colors
loadct,39
back_color=0     ; black
grid_color=255   ; white
de1_color=50     ; dark blue
de4_color=100    ; light blue
p3b_color=35     ; purple P7
p3a_color=50     ; dark blue P6
p3s_color=100    ; light blue P5
p3_color=215     ; orange
p5_color=190     ;yellow
p6_color=255     ;white
p7_color=150     ;green
aindex_color=255 ; white
csize=1.0
chancsize=0.7    ; char size for channel labels
  
!p.multi=[0,1,2,0,0]
xleft=9  ;set xmargin
xright=1

; figure out time ranges and labels
time=long(jday)+(sec/86400.0)
xmin=long(max(jday))-t_arch+1
xmax=long(max(jday))+1
c=where(hhmm eq 0 and jday ge xmin,num_c)
if (num_c lt 1) then c=indgen(n_elements(time))
doyticks=time(c)
nticks=n_elements(doyticks)
xticklab='0'+strcompress(string(fix(da(c))),/remove_all)
for i=0,n_elements(xticklab)-1 do begin
  xticklab(i)=strmid(xticklab(i),strlen(xticklab(i))-2,2)
endfor ; for i=0,n_elements(xticklab)-1 do begin

ymin=min(de4(where(de4 ge 1)))
ymax=max([de1,de4])
print,ymin,ymax
;DE;plot,time,de1,background=back_color,color=grid_color, $
;DE;  xstyle=1,ystyle=1,xrange=[xmin,xmax],yrange=[ymin,ymax],/ylog,/nodata, $
;DE;  charsize=csize,ymargin=[-0.6,4], xmargin=[xleft,xright], $
;DE;  xticks=nticks-1,xtickv=doyticks, $
;DE;  xtickformat='no_axis_labels',xminor=12
;DE;b=where(estat eq 0)
;DE;oplot,time(b),de1(b),psym=3,color=de1_color
;DE;oplot,time(b),de4(b),psym=3,color=de4_color
;DE;yline=1L
;DE;while(yline lt ymax) do begin
;DE;  oplot,[xmin,xmax],[yline,yline],color=grid_color,linestyle=2
;DE;  yline=yline*10
;DE;endwhile ; while(yline lt ymax) do begin
;DE;xyouts,xlabp1,0.78,"Electrons/cm2-s-sr-MeV",orient=90,align=0.5,/norm
;DE;xyouts,xlabp2,0.74,'38-53 ',orient=90,color=de1_color, $
;DE;       /norm,charsize=chancsize
;DE;xyouts,xlabp2,0.81,'175-315 keV',orient=90,color=de4_color, $
;DE;       /norm,charsize=chancsize

ymin=min(p7(where(p7 ge 0.01)))
ymax=max([p3,p3s,p3a,p3b,p5,p6,p7])
plot,time,p3,background=back_color,color=grid_color, $
  xstyle=1,ystyle=1,xrange=[xmin,xmax],yrange=[ymin,ymax],/ylog,/nodata, $
  charsize=csize,ymargin=[-14,4], xmargin=[xleft,xright], $
  ;charsize=csize,ymargin=[-8,1], xmargin=[xleft,xright], $
  xticks=nticks-1,xtickv=doyticks, $
  xtickformat='no_axis_labels',xminor=12
b=where(pstat eq 0)
oplot,time(b),p3a(b),psym=3,color=p3a_color
oplot,time(b),p3b(b),psym=3,color=p3b_color
oplot,time(b),p3s(b),psym=3,color=p3s_color
oplot,time(b),p3(b),psym=3,color=p3_color
oplot,time(b),p5(b),psym=3,color=p5_color
oplot,time(b),p6(b),psym=3,color=p6_color
oplot,time(b),p7(b),psym=3,color=p7_color
oplot,[xmin,xmax],[50000,50000],color=p3_color,thick=1
oplot,[xmin,xmax],[16667,16667],color=p3a_color,thick=1
yline=1L
while(yline lt ymax) do begin
  oplot,[xmin,xmax],[yline,yline],color=grid_color,linestyle=2
  yline=yline*10
endwhile ; while(yline lt ymax) do begin
xyouts,xmin,ymax*1.5,"ACE RTSW (Estimated) EPAM w/ scaled P3",/data,charsize=0.9
;fit=where(time eq min(time))
fit=where(time ge xmin)
fit=fit(sort(fit))
fi=fit(0)
ref_time1=strcompress(string(fix(yr(fi)))+"-",/remove_all)
tt='0'+strcompress(string(fix(mo(fi))),/remove_all)
ref_time1=strcompress(ref_time1+strmid(tt,strlen(tt)-2,2)+"-",/remove_all)
tt='0'+strcompress(string(fix(da(fi))),/remove_all)
ref_time1=strcompress(ref_time1+strmid(tt,strlen(tt)-2,2),/remove_all)
hh='0000'+strcompress(string(fix(hhmm(fi))),/remove_all)
ref_time2=strcompress(strmid(hh,strlen(hh)-4,2)+":"+ $
                      strmid(hh,strlen(hh)-2,2)+":00",/remove_all)
xyouts,xmax,ymax*1.5,"Begin: "+ref_time1+" "+ref_time2+"UTC",/data, $
  align=1.0,charsize=0.9
xlabp1=0.02 ;xposition for units labels (norm coords)
xlabp2=0.040 ;xposition for channel labels (norm coords)
xyouts,xlabp1,0.62,'Protons/cm2-s-sr-MeV',orient=90,align=0.5,/norm
xyouts,xlabp2,0.18,'112-187* ',orient=90,color=p3s_color, $
       /norm,charsize=chancsize
xyouts,xlabp2+(xlabp2-xlabp1),0.22,'(P5)',orient=90,color=p3s_color, $
       /norm,charsize=chancsize
xyouts,xlabp2,0.28,'112-187** ',orient=90,color=p3a_color, $
       /norm,charsize=chancsize
xyouts,xlabp2+(xlabp2-xlabp1),0.32,'(P6)',orient=90,color=p3a_color, $
       /norm,charsize=chancsize
xyouts,xlabp2,0.38,'112-187*** ',orient=90,color=p3b_color, $
       /norm,charsize=chancsize
xyouts,xlabp2+(xlabp2-xlabp1),0.42,'(P7)',orient=90,color=p3b_color, $
       /norm,charsize=chancsize
xyouts,xlabp2,0.50,'115-195 ',orient=90,color=p3_color, $
       /norm,charsize=chancsize
xyouts,xlabp2,0.62,'310-580 ',orient=90,color=p5_color, $
       /norm,charsize=chancsize
xyouts,xlabp2,0.71,'761-1220 ',orient=90,color=p6_color, $
       /norm,charsize=chancsize
xyouts,xlabp2,0.80,'1060-1910 keV',orient=90,color=p7_color, $
       /norm,charsize=chancsize

plot,time,aindex,background=back_color,color=grid_color, $
  xstyle=1,ystyle=1,xrange=[xmin,xmax],yrange=[0,2],/nodata, $
  charsize=csize,ymargin=[4,14.4],xtitle='UTC (days)', xmargin=[xleft,xright], $
  xticks=nticks-1,xtickv=doyticks, $
  xtickname=xticklab,xminor=12,yticks=2,yminor=5
b=where(pstat eq 0)
oplot,time(b),aindex(b),psym=3,color=aindex_color
xyouts,xlabp2,0.12,"Anisotropy",orient=90,/norm,align=0.5,charsize=0.8
xyouts,xlabp2+(xlabp2-xlabp1),0.12,"Index",orient=90,/norm, $
  align=0.5,charsize=0.8

;caldat,systime(/julian),monn,dayn,yrn,hrn,mnn,scn
;print,monn,dayn,yrn,hrn,mnn,scn
;tt='0'+strcompress(string(fix(yrn)),/remove_all)
;ref_time1=strcompress(ref_time1+strmid(tt,strlen(tt)-4,2)+"-",/remove_all)
;tt='0'+strcompress(string(fix(monn)),/remove_all)
;ref_time1=strcompress(ref_time1+strmid(tt,strlen(tt)-2,2)+"-",/remove_all)
;tt='0'+strcompress(string(fix(dayn)),/remove_all)
;ref_time1=strcompress(ref_time1+strmid(tt,strlen(tt)-2,2),/remove_all)
;tt='0'+strcompress(string(fix(hrn)),/remove_all)
;ref_time2=strcompress(ref_time2+strmid(tt,strlen(tt)-2,2)+":",/remove_all)
;tt='0'+strcompress(string(fix(mnn)),/remove_all)
;ref_time2=strcompress(ref_time2+strmid(tt,strlen(tt)-2,2),/remove_all)
;tt='0'+strcompress(string(fix(scn)),/remove_all)
;ref_time2=strcompress(ref_time2+strmid(tt,strlen(tt)-2,2),/remove_all)
;xyouts,0.95,0.02,'Created: '+ref_time1+' '+ref_time2,/norm,align=1.0

xyouts,0.99,0.001,'Created: '+systime()+'ET',/norm,align=1.0,charsize=0.8

mon_len=[0,31,28,31,30,31,30,31,31,30,31,30,31]
doy=total(mon_len[0:fix(mo(fi))-1])
doy=doy+da(fi)

leap=2000
while (yr(fi) ge leap) do begin
  if (yr(fi) eq leap and doy ge 60) then doy=doy+1
  leap=leap+4
endwhile ; while (yr(fi) ge leap) do begin

xyouts,0.08,0.001,'start DOY: '+strcompress(string(fix(doy)),/remove_all), $
  charsize=0.8,/norm

write_gif,'/data/mta4/www/mta_ace_plot_P3.gif',tvrd()
;write_jpeg,'/data/mta4/www/mta_ace_plot.jpg',tvrd()
; png works, but don't know if convert can negate it
;tvlct, red, green, blue, /get
;write_png,'/data/mta4/www/mta_ace_plot.png',rotate(tvrd(),-1),red,green,blue

end
