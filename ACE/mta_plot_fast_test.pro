FUNCTION NO_AXIS_LABELS, axis, index, value
;
;--- suppress labelling axis
;
return, string(" ")
end

PRO MTA_PLOT_FAST_TEST, PLOTX=plotx

;----------------------------------------------------------------------------------
;
;---- mta_plot_ace_p3.pro
;
; make our own ace plot like http://ftp2.sec.noaa.gov/ace/Epam_7d.gif
;  but drop P2, which is broke and replace P3 (also broke) with
;  a scaling from P6 and P7
; 04. Nov 2003 BDS
; 04. Feb 2004 BDS - just plot P3 and scaled P3's for comparison
;
; input data location changed to /data/mta4/proj/rac/ops/ACE/ace.archive
; Oct 22, 2015  TI
;
;----------------------------------------------------------------------------------

; first check for license
;  this is dumb, just crashes before continuing if no license
;if (NOT have_license()) then return

p5_p3_scale = 7         ;--- p5 to p3 scale factor
p6_p3_scale = 36        ;--- p5 to p3 scale factor
p7_p3_scale = 110       ;--- p7 to p3 scale factor
t_arch      = 7         ;--- how many days to plot

ace_7d_archive='../fast.archive'
readcol,ace_7d_archive, $ 

  ;# UT Date   Time  Julian  of the  ----- Electron -----   
  ;# YR MO DA  HHMM    Day    Day    S    38-53   175-315   
  ;
  ;------------------- Protons keV -------------------   
  ;S   65-112   112-187   310-580   761-1220 060-1910   
  ;
  ;Anis. Interpol   Fluence
  ;Ratio   112-187   112-187

  yr,doy,hh,mm,sec,de1,de4,p2,p3,p5,p6,p7, $
  format='F,F,F,F,F,F,F,F,F,F,F,F'
;  skipline=16,format='F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F'
;
;--- and get most recent data
;
readcol,'../fast.archive', $ 
  yr_r,doy_r,hh_r,mm_r,sec_r,de1_r,de4_r,p2_r,p3_r,p5_r,p6_r,p7_r, $
  format='F,F,F,F,F,F,F,F,F,F,F,F'

;
;--- use last45, if something is wrong with 3-day archive
;
spawn,"date '+%Z'",tz                                                   ; jd_now
now = bin_date(systime())                                               ; jd_now
;
;--- make GMT                                                           ; jd_now
;
if (tz(0) eq "EST") then now(3) = now(3) + 5                            ; jd_now
if (tz(0) eq "EDT") then now(3) = now(3) + 4                            ; jd_now
;
;--- idl jd starts at noon, ace starts at 0Z                            ; jd_now
;
jday=doy
jday_r=doy_r
jd_now   = julday(now(1),now(2),now(0),now(3)-12,now(4),now(5))-2400000 ; jd_now
time_r   = long(jday_r) + (sec_r/86400.0)

now_diff = jd_now-max(time_r)

print,"ace.archive is ",now_diff*24.0*60.0," minutes old"  ;debug

if (now_diff gt 0.075) then begin ; close to 2 hrs w/ no new data

    ;dcall_brad, "check ace.archive"  ;debug

    print, "going to last45, check ace.archive"
    ;drdfloat,'last45', $           ;;; check whether this is real function instead of rdfloat (11/19/15)
    ;;;;rdfloat,'last45', $ 
        ;;;;dyr_r,mo_r,da_r,hhmm_r,jday_r,sec_r,estat_r,de1_r,de4_r, $
        ;;;;dpstat_r,p2_r,p3_r,p5_r,p6_r,p7_r,aindex_r

    ;;;;dx1_r = replicate(-1000000,n_elements(yr_r))
    ;;;;dx2_r = replicate(-1000000,n_elements(yr_r))
endif ; if (jd_now-max(time_r) gt 0.075) then begin
;
s_arch = t_arch

if (s_arch lt 14) then s_arch=14

b=where(jday ge max(jday)-s_arch+1,bnum)

time=jday+hh/24.0+mm/1440.0+sec/86000.0
if (bnum gt 0) then begin
    yr     = yr(b)
    hh   = hh(b)
    mm   = mm(b)
    jday   = jday(b)
    sec    = sec(b)
    de1    = de1(b)
    de4    = de4(b)
    p2     = p2(b)
    p3     = p3(b)
    p5     = p5(b)
    p6     = p6(b)
    p7     = p7(b)
    time   = time(b)
endif ; if (bnum gt 0) then begin
;

p3s = p5*p5_p3_scale ; do scaling
p3a = p6*p6_p3_scale ; do scaling
p3b = p7*p7_p3_scale ; do scaling
;
;--- set-up plotting window
;
xwidth  = 640
yheight = 540

if (keyword_set(plotx)) then begin
    set_plot,'x'
    window,0,xsize=xwidth,ysize=yheight

endif else begin
    set_plot,'z'
    device,set_resolution = [xwidth,yheight]
endelse ; 
;
;---set colors and fonts
;
loadct, 39
back_color   = 0    ; black
grid_color   = 255  ; white
de1_color    = 50   ; dark blue
de4_color    = 100  ; light blue
p3b_color    = 35   ; purple P7
p3a_color    = 50   ; dark blue P6
p3s_color    = 100  ; light blue P5
p3_color     = 215  ; orange
p5_color     = 190  ; yellow
p6_color     = 255  ; white
p7_color     = 150  ; green
aindex_color = 255  ; white

csize        = 1.0
chancsize    = 0.7  ; char size for channel labels
;
;--- set xmargin
;
xleft  = 9
xright = 1

!p.multi = [0,1,2,0,0]
;
;--- figure out time ranges and labels
;
time = long(jday)+(sec/86400.0)
xmin = long(max(jday)) - t_arch + 1
xmax = long(max(jday)) + 1
c    = where(hh eq 0 and mm eq 0 and jday ge xmin,num_c)

if (num_c lt 1) then c=indgen(n_elements(time))

doyticks = time(c)
nticks   = n_elements(doyticks)
xticklab = '0'+strcompress(string(fix(doy(c))),/remove_all)

for i=0,n_elements(xticklab)-1 do begin
    xticklab(i)=strmid(xticklab(i),strlen(xticklab(i))-2,2)
endfor ; for i=0,n_elements(xticklab)-1 do begin

ymin = min(de4(where(de4 ge 1)))
ymax = max([de1,de4])

print,ymin,ymax

ymin = min(p7(where(p7 ge 0.01)))
ymax = max([p3,p3s,p3a,p3b,p5,p6,p7])

plot,time, p3, background=back_color, color=grid_color, $
     xstyle=1, ystyle=1, xrange=[xmin,xmax], yrange=[ymin,ymax], /ylog,/nodata, $
     charsize=csize, ymargin=[-14,4], xmargin=[xleft,xright], $
     ;charsize=csize, ymargin=[-8,1], xmargin=[xleft,xright], $
     xticks=nticks-1, xtickv=doyticks, $
     xtickformat='no_axis_labels', xminor=12

;;;b = where(pstat eq 0)
b=indgen(n_elements(time))
oplot, time(b),    p3a(b), psym=3, color=p3a_color
oplot, time(b),    p3b(b), psym=3, color=p3b_color
oplot, time(b),    p3s(b), psym=3, color=p3s_color
oplot, time(b),    p3(b),  psym=3, color=p3_color
oplot, time(b),    p5(b),  psym=3, color=p5_color
oplot, time(b),    p6(b),  psym=3, color=p6_color
oplot, time(b),    p7(b),  psym=3, color=p7_color
oplot, [xmin,xmax],[50000,50000],  color=p3_color,  thick=1
oplot, [xmin,xmax],[16667,16667],  color=p3a_color, thick=1

yline=1L

while(yline lt ymax) do begin
    oplot,[xmin,xmax],[yline,yline],color=grid_color,linestyle=2
    yline=yline*10
endwhile ; while(yline lt ymax) do begin

xyouts,xmin,ymax*1.5,"ACE RTSW (Estimated) EPAM w/ scaled P3",/data,charsize=0.9

fit       = where(time ge xmin)
fit       = fit(sort(fit))
fi        = fit(0)

xlabp1    = 0.02        ;--- xposition for units labels (norm coords)
xlabp2    = 0.040       ;--- xposition for channel labels (norm coords)

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

xyouts,0.99,0.001,'Created: '+systime()+'ET',/norm,align=1.0,charsize=0.8

;;;mon_len = [0,31,28,31,30,31,30,31,31,30,31,30,31]
;;;doy     = total(mon_len[0:fix(mo(fi))-1])
;;;doy     = doy+da(fi)

leap = 2000

;;;while (yr(fi) ge leap) do begin
    ;;;if (yr(fi) eq leap and doy ge 60) then doy = doy + 1
    ;;;leap = leap + 4
;;;endwhile ; while (yr(fi) ge leap) do begin

xyouts, 0.08, 0.001, 'start DOY: '+strcompress(string(fix(doy)),/remove_all), $
        charsize = 0.8,/norm

write_gif,'/data/mta4/www/mta_ace_plot_fast.gif',tvrd()

end
