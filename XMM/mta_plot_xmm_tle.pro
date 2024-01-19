PRO MTA_PLOT_XMM_TLE, XMIN, XMAX, PLOTX=plotx

;------------------------------------------------------------------------
; plot xmm ephemeris
;
; specify exact bounds of x axis (in days since 1/1/1998) to match
;  xmm_rad plot
; 21.jul2004 bds
;
;   last update: FEb 29, 2016   ti
;
;------------------------------------------------------------------------
;
;--- set colors
;
loadct, 39
back_color = 0      ; black
grid_color = 255    ; white
dblue      = 50     ; dark blue
lblue      = 100    ; light blue
red        = 230    ; red
orange     = 215    ; orange
yellow     = 190    ; yellow
green      = 150    ; green
csize      = 2.0
chancsize  = 0.7    ; char size for channel labels
;
;--- set xmargin
;
xleft      = 15 
xright     = 1
;
;--- read XMM orbit information
;
tlefile = "/proj/rac/ops/ephem/TLE/xmm.spctrk"
readcol, tlefile, sec, yy, dd, hh, mm, ss, x_eci, y_eci, z_eci, vx, vy, vz,  $
        format='L,I,I,I,I,I,F,F,F,F,F,F', skipline=5
;
;--- convert time in day of the year
;
sec      = sec - 8.83613e+08-86400.0
;time     = (sec/60./60./24.)-2190.0-366.-365.-365.-365.-366.-(6*365.) ; 2010 days
time     = (sec/60./60./24.)-2190.0-366.-365.-365.-365.-366.-365. ; 2010 days
;
;--- convert jday to this year's yday
;
atime    = systime()
atemp    = strsplit(atime,/extract)
dyear    = fix(atemp[4]) - 2010             ; ---- how many years from 2010?
;
;-- check how many leap years between 2010 and this year (not including this year)
;
ladd     = (dyear + 1) / 4                  
time     = time - (365 * dyear + ladd) - 1

nel      = n_elements(sec)
es       = lonarr(nel)
x_gsm    = fltarr(nel)
y_gsm    = fltarr(nel)
z_gsm    = fltarr(nel)

mon_days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

for i = 0, n_elements(sec)-1 do begin
    mon_days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    leap     = 2000
    
    while (yy(i) ge leap) do begin
        if (yy(i) eq leap) then mon_days(1)=29
        leap = leap + 4
    endwhile ; while (yy(i) ge leap) do begin
    
    mon = 1
    day = dd(i)
    
    while (day gt mon_days(mon-1)) do begin
        day = day - mon_days(mon-1)
        mon = mon + 1
    endwhile ;while (day gt mon_days(mon-1)) do begin
  
endfor ;for i=0, n_elements(sec)-1 do begin

r_eci=sqrt(x_eci^2+y_eci^2+z_eci^2)/1000.0

;
;--- figure out time ranges and labels
;
t_arch   = fix(xmax-xmin)
doyticks = indgen(t_arch)+floor(min(xmin))
nticks   = n_elements(doyticks)
xticklab = strcompress(string(doyticks+1), /remove_all)

ymin     = min(r_eci)
ymax     = max(r_eci)
;
;--- set plotting frame
;
plot, time, r_eci, background=back_color, color=grid_color,  $
      xstyle=1, ystyle=1, xrange=[xmin, xmax], yrange=[ymin, ymax], /nodata,  $
      charsize=csize, ymargin=[-12, 18],  xmargin=[xleft, xright],  $
      xticks=nticks-1, xtickv=doyticks,  ytitle="Altitude (kkm)",  $
      xtickname=xticklab, xminor=12,  $
      xtitle=""
;
;--- plot data 
;
oplot, time, r_eci, color=lblue

;write_gif, '/data/mta4/www/RADIATION/XMM/mta_xmm_plot_tle.gif', tvrd()

end
