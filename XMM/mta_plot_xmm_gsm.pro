PRO MTA_PLOT_XMM_GSM,PLOTX=plotx

;-----------------------------------------------------------------
; plot xmm/cxo ephemeris
;
;  written by b. spitzbart (bspitzbart@cfa.harvard.edu)
;
;  updated by t. isobe (tisobe@cfa.harvard.edu) Nov 02, 2015
;-----------------------------------------------------------------

Re = 6378.0 ; earth radius
;
;--- read XMM orbit
;
xmmfile = "/data/mta4/proj/rac/ops/ephem/TLE/xmm.spctrk"
readcol,xmmfile,sec,yy,dd,hh,mm,ss,x_eci,y_eci,z_eci,vx,vy,vz, $
        format = 'L,I,I,I,I,I,F,F,F,F,F,F',skipline=5
sec  = sec-long(8.83613e+08)-86400L
time = sec/60./60./24.
;
;--- read CXO orbit
;
cxofile = "/data/mta4/proj/rac/ops/ephem/TLE/cxo.spctrk"
readcol,cxofile,cxo_sec,cxo_yy,cxo_dd,cxo_hh,cxo_mm,cxo_ss, $
        cxo_x_eci,cxo_y_eci,cxo_z_eci,cxo_vx,cxo_vy,cxo_vz, $
        format='L,I,I,I,I,I,F,F,F,F,F,F',skipline=5
cxo_sec  = cxo_sec-long(8.83613e+08)-86400L
cxo_time = cxo_sec/60./60./24.

mon_days = [31,28,31,30,31,30,31,31,30,31,30,31]
;
;--- opening debuggin output files
;
openw,tunit,"xdate",/get_lun   ;debug
openw,cunit,"xcoords",/get_lun ;debug
;
;--- converting XMM coordinates to GSM
;
nel   = n_elements(sec)-2
es    = lonarr(nel)
x_gsm = fltarr(nel)
y_gsm = fltarr(nel)
z_gsm = fltarr(nel)

for i = 0,n_elements(sec)-3 do begin
    mon_days = [31,28,31,30,31,30,31,31,30,31,30,31]

    leap = 2000
    while (yy(i) ge leap) do begin
        if (yy(i) eq leap) then mon_days(1)=29
        leap=leap + 4
    endwhile ; while (yy(i) ge leap) do begin
    
    mon = 1
    day = dd(i)
    while (day gt mon_days(mon-1)) do begin
        day = day - mon_days(mon-1)
        mon = mon+1
    endwhile ;while (day gt mon_days(mon-1)) do begin
    
    printf,tunit,yy(i),dd(i),mon,day ;debug
    
    es(i)    = date2es(mon,day,yy(i),hh(i),mm(i),ss(i))
    gsm      = cxform([x_eci(i),y_eci(i),z_eci(i)],'GEI','GSM',es(i))
    x_gsm(i) = gsm(0)
    y_gsm(i) = gsm(1)
    z_gsm(i) = gsm(2)
    
    printf,tunit,yy(i),dd(i),mon,day,es(i) ;debug
    printf,cunit,"ECI ",x_eci(i),y_eci(i),z_eci(i)  ;debug
    printf,cunit,"GSM ",x_gsm(i),y_gsm(i),z_gsm(i)  ;debug
     
endfor ;for i=0,n_elements(sec)-1 do begin

free_lun,tunit ;debug
free_lun,cunit ;debug
;
;--- converting CXO coordinates to GSM
;
nel=n_elements(cxo_sec)-2
es=lonarr(nel)
cxo_x_gsm=fltarr(nel)
cxo_y_gsm=fltarr(nel)
cxo_z_gsm=fltarr(nel)

for i=0,n_elements(cxo_sec)-3 do begin
    mon_days=[31,28,31,30,31,30,31,31,30,31,30,31]
    leap=2000
    
    while (cxo_yy(i) ge leap) do begin
        if (cxo_yy(i) eq leap) then mon_days(1)=29
        leap = leap + 4
    endwhile ; while (yy(i) ge leap) do begin
    
    mon = 1
    day = cxo_dd(i)
    
    while (day gt mon_days(mon-1)) do begin
        day = day - mon_days(mon-1)
        mon = mon + 1
    endwhile ;while (day gt mon_days(mon-1)) do begin
    
    es(i) = date2es(mon,day,cxo_yy(i),cxo_hh(i),cxo_mm(i),cxo_ss(i))
    gsm   = cxform([cxo_x_eci(i),cxo_y_eci(i),cxo_z_eci(i)],'GEI','GSM',es(i))
    cxo_x_gsm(i) = gsm(0)
    cxo_y_gsm(i) = gsm(1)
    cxo_z_gsm(i) = gsm(2)
endfor ;for i=0,n_elements(sec)-1 do begin
;
;--- setting plotting area
;
xwidth  = 640
yheight = 640
if (keyword_set(plotx)) then begin
    set_plot,'x'
    window,0,xsize=xwidth,ysize=yheight
endif else begin
    set_plot,'z'
    device,set_resolution = [xwidth,yheight]
endelse ;

r_eci = sqrt(x_eci^2+y_eci^2+z_eci^2) / 1000.0
r_gsm = sqrt(x_gsm^2+y_gsm^2+z_gsm^2)
;
;---set colors/character sizes
;
loadct,39           ; system color table

back_color = 0      ; black
grid_color = 255    ; white
dblue      = 50     ; dark blue
lblue      = 100    ; light blue
red        = 230    ; red
orange     = 215    ; orange
yellow     = 190    ; yellow
green      = 150    ; green
csize      = 1.0
chancsize  = 0.7    ; char size for channel labels

!p.multi=[0,1,1,0,0]
;
;--- selecting time period for XMM --- +/- 0.9 day
;
curr_time = systime(/sec) - 8.83613e8
;b         = where(sec gt curr_time-0.9*86400. and sec lt curr_time+0.9*86400.)
b         = where(sec gt curr_time-1.35*86400. and sec lt curr_time+1.35*86400.)
sec       = sec(b)

print,min(sec),"min sec"

x_gsm = x_gsm(b)
y_gsm = y_gsm(b)
z_gsm = z_gsm(b)

x_eci = x_eci(b)
y_eci = y_eci(b)
z_eci = z_eci(b)

vx    = vx(b)
vy    = vy(b)
vz    = vz(b)
;
;--- selecting time period for CXO --- +/- 1.35 days
;
b=where(cxo_sec gt curr_time-1.35*86400. and cxo_sec lt curr_time+1.35*86400.)
cxo_sec   = cxo_sec(b)
cxo_x_gsm = cxo_x_gsm(b)
cxo_y_gsm = cxo_y_gsm(b)
cxo_z_gsm = cxo_z_gsm(b)
cxo_x_eci = cxo_x_eci(b)
cxo_y_eci = cxo_y_eci(b)
cxo_z_eci = cxo_z_eci(b)
cxo_vx    = cxo_vx(b)
cxo_vy    = cxo_vy(b)
cxo_vz    = cxo_vz(b)
;
;--- setting up plot environment
;
plot,x_gsm/Re, y_gsm/Re, background=back_color, color=grid_color, /isotropic, $
  xrange=[-20, 20], yrange=[-20, 20],/nodata, $
  xtitle="X_GSM (R!lE!n)", ytitle="Y_GSM (R!lE!n)"
;
;---- oplot xmm crm regions
;
oplot,x_gsm/Re,y_gsm/Re,color=red

readcol,'crmreg_xmm.dat',Csec,CR,CXgsm,CYgsm,CZgsm,Ccrmreg, $
         format='L,F,F,F,F,I',skipline=5
;
;--- now mark with crm coding
;
crm_color=indgen(n_elements(sec))

for i = 0, n_elements(sec)-1,1 do begin
    diff=abs(long(sec(i))-long(Csec))
    b=where(diff eq min(diff))
    if (Ccrmreg(b(0)) eq 1) then crm_color(i) = 150
    if (Ccrmreg(b(0)) eq 2) then crm_color(i) = 100
    if (Ccrmreg(b(0)) eq 3) then crm_color(i) = 190
endfor ; for i=0,n_elements(cxo_sec)-1,1 do begin
;
;--- XMM orbit is marked with dashed line
;
plots,x_gsm/Re,y_gsm/Re,color=crm_color,linestyle=2

bn = n_elements(x_gsm)
oplot,[x_gsm[bn-1]/Re,x_gsm[bn-1]/Re], $
      [y_gsm[bn-1]/Re,y_gsm[bn-1]/Re], color=crm_color[bn-1], $
      thick=4,psym=1
xmm_color = crm_color
;
;--- find the current postion by  finding the position less than 1000 sec from current time
;
sec_mark = curr_time
b        = where(abs(sec-sec_mark) lt 1000.0,bnum)
orb      = 0

if (bnum gt 0) then $  ; mark current position
    start_x = x_gsm(b(0))
    start_y = y_gsm(b(0))

oplot,[x_gsm(b(0)), x_gsm(b(0))]/Re, [y_gsm(b(0)),y_gsm(b(0))]/Re, $
       color=green, psym=2, symsize=2

sec_mark = sec_mark-86400L

while (sec_mark gt min(sec)) do begin
    b=where(abs(sec-sec_mark) lt 1000.0,bnum)
    orb=orb+1
    if (bnum gt 0) then $
        
        oplot,[x_gsm(b(0)),x_gsm(b(0))]/Re, [y_gsm(b(0)), y_gsm(b(0))]/Re, $
               color=red, psym=2
    
    sec_mark=sec_mark-86400L
endwhile ; while (sec_mark gt min(sec)) do begin
;
;--- read CXO CRMREG data
;
readcol,'crmreg_cxo.dat', Csec,CR, CXgsm, CYgsm, CZgsm, Ccrmreg, $
        format='L,F,F,F,F,I',skipline=5
crm_color = indgen(n_elements(cxo_sec))

print,cxo_sec(0:5) ; debugcolor
print,Csec(0:5) ; debugcolor

for i = 0, n_elements(cxo_sec)-1,1 do begin
    diff = abs(long(cxo_sec(i))-long(Csec))
    b    = where(diff eq min(diff))
    
    print, cxo_sec(i),Csec(b(0)),b(0) ;debugcolor
    
    if (Ccrmreg(b(0)) eq 1) then crm_color(i) = 150
    if (Ccrmreg(b(0)) eq 2) then crm_color(i) = 100
    if (Ccrmreg(b(0)) eq 3) then crm_color(i) = 190
endfor ; for i=0,n_elements(cxo_sec)-1,1 do begin

;print,crm_color ;debugcolor

;
;--- plot CXO positions with the crm color 
;
plots, cxo_x_gsm/Re, cxo_y_gsm/Re, color=crm_color
bn = n_elements(cxo_x_gsm)

oplot,[cxo_x_gsm[bn-1]/Re,cxo_x_gsm[bn-1]/Re], $
      [cxo_y_gsm[bn-1]/Re,cxo_y_gsm[bn-1]/Re], color=crm_color[bn-1], $
      thick=4,psym=1

;
;---- find the current CXO position
;
sec_mark = curr_time
b        = where(abs(cxo_sec-sec_mark) lt 1000,bnum)
orb      = 0

if (bnum gt 0) then begin 
  oplot,[cxo_x_gsm(b(0)),cxo_x_gsm(b(0))]/Re, $
        [cxo_y_gsm(b(0)),cxo_y_gsm(b(0))]/Re, $
        color=green,psym=2,symsize=2

  print,sec_mark ; debug
  print,b(0),cxo_sec(b(0)),cxo_x_gsm(b(0)),cxo_y_gsm(b(0)),cxo_z_gsm(b(0)) ;debug
  print,cxo_x_eci(b(0)),cxo_y_eci(b(0)),cxo_z_eci(b(0)) ;debug
  print,b(n_elements(b)-1),cxo_sec(b(n_elements(b)-1)),cxo_x_gsm(b(n_elements(b)-1)) ; debug

endif ;if (bnum gt 0) then begin ; mark current position

sec_mark=sec_mark-86400L

while (sec_mark gt min(cxo_sec)) do begin
    b   = where(abs(cxo_sec-sec_mark) lt 1000.0,bnum)
    orb = orb + 1
    
    if (bnum gt 0) then begin
        ;xyouts, $
        ;[cxo_x_gsm(b(0)),cxo_x_gsm(b(0))]/Re, $
        ;[cxo_y_gsm(b(0)),cxo_y_gsm(b(0))]/Re, $
        ;strcompress(string(orb)),color=red
        oplot, $
        [cxo_x_gsm(b(0)),cxo_x_gsm(b(0))]/Re, $
        [cxo_y_gsm(b(0)),cxo_y_gsm(b(0))]/Re, $
        color=red,psym=2
    endif ; if (bnum gt 0) then begin
    
    sec_mark=sec_mark-86400.
endwhile ; while (sec_mark gt min(cxo_sec)) do begin

oplot,[0,0], [0,0], psym=1, color=255

xm        = indgen(Re)/Re*7.0
mag_shape = sqrt(49.0-xm^2)
;
;---  magnetosheath
;
oplot,xm, mag_shape,      color=lblue 
oplot,xm, -1.0*mag_shape, color=lblue 

xm = indgen(Re)/Re*3.0
;
;--- van allen belts
;
oplot, xm,sqrt(9.0-xm^2),      color=orange 
oplot, xm,-1.0*sqrt(9.0-xm^2), color=orange 
oplot,-xm,sqrt(9.0-xm^2),      color=orange 
oplot,-xm,-1.0*sqrt(9.0-xm^2), color=orange
;
;--- sun direciton
;
xyouts,14.0,0.5,"SUN ", color=yellow
arrow,13,0,18,0,/data,  color=yellow
;
;--- legends
;
oplot,[-15,-11],[17.7,17.7],color=grid_color,linestyle=0
oplot,[-15,-11],[14.7,14.7],color=grid_color,linestyle=2

xyouts,-10.0,17.0,"CXO",color=grid_color,charsize=2
xyouts,-10.0,14.0,"XMM",color=grid_color,charsize=2
xyouts,11,17,"nom. magnetosheath",color=lblue,charsize=0.8
xyouts,11,15,"nom. Van Allen belts",color=orange,charsize=0.8
xyouts,-3.0,-16.2,"current position",color=green,charsize=1.2
;xyouts,-4.5,-18.2,"!8n!X",color=red,charsize=1.2
;xyouts,-3.0,-18.2,"current minus !8n!X days position (CXO)",color=red,charsize=1.2
xyouts,-3.0,-18.2,"current minus one day position",color=red,charsize=1.2

oplot,[-5,-5],[-16,-16],psym=2,color=green,symsize=2
oplot,[-5,-5],[-18,-18],psym=2,color=red
;;;
;;;---- ti commented out the following part x-z and y-z plane plots
;;;
;;;b=n_elements(cxo_x_gsm)-1
;;;plot,x_gsm,z_gsm,background=back_color,color=grid_color,/isotropic, $
;;;  xrange=[xmin,xmax],yrange=[xmin,xmax],/nodata, $
;;;  xtitle="X_GSM",ytitle="Z_GSM"
;;;oplot,x_gsm,z_gsm,color=red
;;;oplot,cxo_x_gsm,cxo_z_gsm,color=lblue
;;;oplot,[0,0],[0,0],psym=1,color=255
;;;plot,y_gsm,z_gsm,background=back_color,color=grid_color,/isotropic, $
;;;  xrange=[xmin,xmax],yrange=[xmin,xmax],/nodata, $
;;;  xtitle="Y_GSM",ytitle="Z_GSM"
;;;oplot,y_gsm,z_gsm,color=red
;;;oplot,cxo_y_gsm,cxo_z_gsm,color=lblue
;;;oplot,[0,0],[0,0],psym=1,color=255

;
;---- verify calc
;
;;;rdfloat,'/proj/rac/ops/ephem/TLE/xmm.gsme_in_Re',t,gx,gy,gz,x,y,z,y,m,d,h,n,s
;;;oplot,gx*1000.0,gy*1000.0,color=orange
;;;rdfloat,'./cxo.gsme_in_Re',t,gx,gy,gz,x,y,z,y,m,d,h,n,s
;;;oplot,gx*1000.0,gy*1000.0,color=orange
;;;xyouts,0.99,0.001,'Created: '+systime()+'ET',/norm,align=1.0,charsize=0.8
write_gif,'/data/mta4/www/RADIATION/XMM/mta_xmm_plot_gsm.gif',tvrd()
print, "check here"

;eci;!p.multi=[0,2,2,0,0]
;eci;xmin=min([x_eci,y_eci,z_eci,cxo_x_eci,cxo_y_eci,cxo_z_eci])
;eci;xmax=max([x_eci,y_eci,z_eci,cxo_x_eci,cxo_y_eci,cxo_z_eci])
;eci;plot,x_eci,y_eci,background=back_color,color=grid_color,/isotropic, $
;eci;  xrange=[xmin,xmax],yrange=[xmin,xmax],/nodata, $
;eci;  xtitle="X_ECI",ytitle="Y_ECI"
;eci;oplot,x_eci,y_eci,color=red
;eci;oplot,cxo_x_eci,cxo_y_eci,color=lblue
;eci;oplot,[0,0],[0,0],psym=1,color=255
;eci;plot,x_eci,z_eci,background=back_color,color=grid_color,/isotropic, $
;eci;  xrange=[xmin,xmax],yrange=[xmin,xmax],/nodata, $
;eci;  xtitle="X_ECI",ytitle="Z_ECI"
;eci;oplot,x_eci,z_eci,color=red
;eci;oplot,cxo_x_eci,cxo_z_eci,color=lblue
;eci;oplot,[0,0],[0,0],psym=1,color=255
;eci;plot,y_eci,z_eci,background=back_color,color=grid_color,/isotropic, $
;eci;  xrange=[xmin,xmax],yrange=[xmin,xmax],/nodata, $
;eci;  xtitle="Y_ECI",ytitle="Z_ECI"
;eci;oplot,y_eci,z_eci,color=red
;eci;oplot,cxo_y_eci,cxo_z_eci,color=lblue
;eci;oplot,[0,0],[0,0],psym=1,color=255
;eci;
;eci; write_gif,'/data/mta4/www/RADIATION/XMM/mta_xmm_plot_eci.gif',tvrd()

openw,cdat,"xcxo.gsm.dat",/get_lun
for i=0,n_elements(cxo_x_gsm)-1,1 do begin
  printf,cdat,cxo_sec(i),cxo_x_gsm(i),cxo_y_gsm(i),cxo_z_gsm(i)
endfor

free_lun,cdat

crm_color=100
xmm_color=200
plot,sec,x_gsm/Re,color=grid_color,psym=3, $
  xtitle="time",ytitle="X_GSM (R!lE!n)",/nodata
oplot,sec,x_gsm/Re,color=xmm_color,psym=3
oplot,cxo_sec,cxo_x_gsm/Re,color=crm_color
write_gif,"/data/mta4/www/RADIATION/XMM/time_x.gif",tvrd()

plot,sec,y_gsm/Re,color=grid_color,psym=3, $
  xtitle="time",ytitle="Y_GSM (R!lE!n)",/nodata
oplot,sec,y_gsm/Re,color=xmm_color,psym=3
oplot,cxo_sec,cxo_y_gsm/Re,color=crm_color
write_gif,"/data/mta4/www/RADIATION/XMM/time_y.gif",tvrd()

plot,sec,z_gsm/Re,color=grid_color,psym=3, $
  xtitle="time",ytitle="Z_GSM (R!lE!n)",/nodata
oplot,sec,z_gsm/Re,color=xmm_color,psym=3
oplot,cxo_sec,cxo_z_gsm/Re,color=crm_color
write_gif,"/data/mta4/www/RADIATION/XMM/time_z.gif",tvrd()


end
