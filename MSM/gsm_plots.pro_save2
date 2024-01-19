; Prepare several orbital plots
;
; Scott Wolk
; June 2000
;
; August 17 2000
; set x,y, and z axis to -20 to  20 
;
; April 12,2004 removed planer plot code 
; since NOAA no longer models particles in plane.
; 
; May 15, 2018 input file changed   (TI)
;


file ='/proj/rac/ops/ephem/PE.EPH.gsme_in_Re'
wwwdir = '/data/mta4/www/RADIATION/'
           
version = strcompress(fix(randomu(seed)*100.),/rem)

; PREPARE THE PLOT  CANVAS
zee =  1
read_gif,'/data/mta4/space_weather/MSM/FluxImageColorKey.gif', key, r, g, b
IF (zee eq  1) THEN BEGIN 
    set_plot, 'z'
    device, set_resolution= [512,512]
    tvlct,  r, g, b
ENDIF ELSE BEGIN
    set_plot, 'x'
    WINDOW,  0, XSIZE = 512, YSIZE = 512
ENDELSE 

; GET CHANDRA ORBITAL DATA

rows= file_lines(file)
a=dblarr(13,rows)
openr,1,file
readf,1,a
close, 1

dist=a(1,*)
longgse=a(5,*)
latgse=a(4,*)
;dist=dist/6378.17
longgsm=a(3,*)
latgsm=a(2,*)


;CONVERT TO POLAR COORDINATES
xgse=dist*sin(latgse * !pi/180.)*cos(longgse * !pi/180)
ygse=dist*sin(latgse * !pi/180.)*sin(longgse * !pi/180)
;ygse = -ygse
zgse=dist*cos(latgse *!pi/180.)
xgsm=dist*sin(latgsm * !pi/180.)*cos(longgsm * !pi/180)
ygsm=dist*sin(latgsm * !pi/180.)*sin(longgsm * !pi/180)
;ygsm = -ygsm
zgsm=dist*cos(latgsm *!pi/180.)

;;year=fix(a(6,*))
;;month=a(7,*)
;;day=a(8,*)
;;hour=a(9,*)    
;;min=a(10,*)

year=fix(a(7,*))
month=a(8,*)
day=a(9,*)
hour=a(10,*)    
min=a(11,*)
k=where (hour eq 0 and min eq 3)

date =  strmid (fix(month(k(0))),5,3) + strmid(fix(day(k(0))),5,3)+strmid(fix(year(k(0))),3,5)

spawn, 'rm '+wwwdir+'/GS*.gif'
;spawn, 'rm '+wwwdir+'/GS*.jpg'
;spawn, 'ln -s /proj/rac/ops/ephem/GSE.gif ' +wwwdir+'GSE'+version+'.gif'
;spawn, 'ln -s /proj/rac/ops/ephem/GSM.gif ' +wwwdir+'GSM'+version+'.gif'
spawn, 'ln -s /proj/rac/ops/ephem/GSE.gif ' +wwwdir+'GSE.gif'
spawn, 'ln -s /proj/rac/ops/ephem/GSM.gif ' +wwwdir+'GSM.gif'

;PLOT ORBIT
IF zee EQ  1 THEN device, set_resolution= [640,480]
set_xy,-20,20,-20,20
set_viewport,.15,.85,.15,.85  

tit =  'GSE Orbit '+ date
plot_3dbox,xgse(0,*),ygse(0,*),zgse(0,*),psym=5,/xz_plane,/xy_plane,/yz_plane, tit = tit, chars = 2, symsize = .7, xtit = 'Xgse (Re)', ytit = 'Ygse (Re)', ztit = 'Zgse (Re)', zrange = [-20, 20]

;OVERLAY EARTH 
plots,0,0,0,psym=2,symsize=6,/T3D, col = 125
plots,0,0,!z.crange(0),psym=2,symsize=3,/T3D, col = 125
plots,0,!y.crange(1),0,psym=2,symsize=3,/T3D, col = 125
plots,!x.crange(1),0,0,psym=2,symsize=3,/T3D, col = 125

;MARK POSITION AT at CERTAIN DATES
plots, xgse(k),ygse(k), zgse(k), psym = 4, symsize = 4, /t3d, col = 230
plots, xgse(k),ygse(k),!z.crange(0), psym = 4, symsize = 4, /t3d, col = 230
FOR i = 0, n_elements(k) -1 DO BEGIN
    text = strmid (fix(month(k(i))),5,3) + strmid(fix(day(k(i))),5,3)
    xyouts, xgse(k(i)),ygse(k(i)), z = zgse(k(i)), text, chars = 3, /t3d, col = 230
    xyouts, xgse(k(i)),ygse(k(i)), z = !z.crange(0), text, chars = 3, /t3d, col = 230
;    xyouts, xgse(k(i)),!y.crange(1), z = zgse(k(i)), text, chars = 3, /t3d, col = 230
;    xyouts, !x.crange(1),ygse(k(i)), z = zgse(k(i)), text, chars = 3, /t3d, col = 230
ENDFOR 

IF (zee eq  1) THEN BEGIN 
    out = tvrd()
    ;COMMENT OUT April 13 2004 TBR
    ;WRITE_GIF, wwwdir+'GSEORBIT'+version+'.gif', out, R, G, B
    WRITE_GIF, wwwdir+'GSEORBIT.gif', out, R, G, B
ENDIF 



;PLOT GSM ORBIT
tit =  'GSM Orbit '+ date
plot_3dbox,xgsm(0,*),ygsm(0,*),zgsm(0,*),psym=5,/xz_plane,/xy_plane,/yz_plane, tit = tit, chars = 2, symsize = .7, xtit = 'Xgsm (Re)', ytit = 'Ygsm (Re)', ztit = 'Zgsm (Re)', zrange = [-20, 20]

;OVERLAY EARTH 
plots,0,0,0,psym=2,symsize=6,/T3D, col = 125
plots,0,0,!z.crange(0),psym=2,symsize=3,/T3D, col = 125
plots,0,!y.crange(1),0,psym=2,symsize=3,/T3D, col = 125
plots,!x.crange(1),0,0,psym=2,symsize=3,/T3D, col = 125


;MARK POSITION AT 00UT at CERTAIN DATES
plots, xgsm(k),ygsm(K), zgsm(K), psym = 4, symsize = 4, /t3d, col = 230
plots, xgsm(k),ygsm(K),!z.crange(0), psym = 4, symsize = 4, /t3d, col = 230
FOR i = 0, n_elements(k) -1 DO BEGIN
    text = strmid (fix(month(k(i))),5,3) + strmid(fix(day(k(i))),5,3)
    xyouts, xgsm(k(i)),ygsm(K(i)), z = zgsm(K(i)), text, chars = 3, /t3d, col = 230
    xyouts, xgsm(k(i)),ygsm(K(i)), z = !z.crange(0), text, chars = 3, /t3d, col = 230
;    xyouts, xgsm(k(i)),!y.crange(1), z = zgsm(K(i)), text, chars = 3, /t3d, col = 230
;    xyouts, !x.crange(1),ygsm(K(i)), z = zgsm(K(i)), text, chars = 3, /t3d, col = 230
ENDFOR 

;PLOT A ROUGH MAG FIELD 
inde=indgen(400)
inde= inde-200
inde= inde/80.   
plots, -inde^2+7, 9*inde, !z.crange(0), /t3d, col = 60,  clip =  [!x.crange(0), !y.range(0), !x.crange(1), !y.range(1)]

IF (zee eq  1) THEN BEGIN 
    out = tvrd()
   ; WRITE_GIF, wwwdir+'GSMORBIT'+version+'.gif', out, R, G, B
    WRITE_GIF, wwwdir+'GSMORBIT.gif', out, R, G, B
ENDIF 


;openw, 2, '/data/mta4/www/orbit.html'
;printf, 2, '<HTML>'
;printf, 2, '<HEAD>'
;printf, 2, '<TITLE>Chandra Orbit </TITLE>'
;printf, 2, '</HEAD>'
;printf, 2, '<BODY TEXT="#DDDDDD" BGCOLOR="#000000" LINK="#FF0000" VLINK="#FFFF22" ALINK="#7500FF">'

;printf, 2, '<center>'
;printf, 2, '<h2>The Current Orbital Profile</h2>'
;printf, 2, '<h4>All dates 00 hours UT</h4>'
;printf, 2, '</center>'

;printf, 2, '<HR> <a href="http://www.spenvis.oma.be/spenvis/help/background/coortran/coortran.html">SPENVIS </a> The coordinate systems and transformations used here.<br>'

;printf, 2, '<a href="./RADIATION"> Radiation Monitoring central page. </a><br>' 

;printf, 2, '<a href="sot.html"> SOT home page. </a><br>'


;printf, 2, '<HR><CENTER><h4>GSE Orbit</h4><IMG SRC="./RADIATION/GSEORBIT'+version+'.gif"></CENTER>'
;printf, 2, '<HR><CENTER><h4>GSM Orbit</h4><IMG SRC="./RADIATION/GSMORBIT'+version+'.gif"></CENTER>'
;printf, 2, '<HR><CENTER><h4>Planar projection of GSM Orbit is no longer available.</h4> <!-- <IMG SRC="./GSMKP'+version+'.gif">  --!>  </CENTER>'
;printf, 2, '<HR><CENTER><h4>GSE: DIST, LON, LAT, COM</h4><IMG SRC="./RADIATION/GSE'+version+'.gif"></CENTER>'
;printf, 2, '<HR><CENTER><h4>GSM: DIST, LON, LAT, COM</h4><IMG SRC="./RADIATION/GSM'+version+'.gif"></CENTER><BR>'

;printf, 2, '<HR><CENTER><h4>Plot of predicted future Chandra radiation, with SI config and DSN schedule plots</h4>(Updated every 5 minutes, WITHOUT radiation attenuation appropriate for SIM and OTG positions).</h4><IMG SRC="./RADIATION/crmpl.gif"></CENTER>'

;printf, 2, '<HR><CENTER><h4>Plot of predicted future Chandra radiation, with SI config and DSN schedule plots</h4> (Updated every 5 minutes, WITH radiation attenuation appropriate for SIM and OTG positions).</h4><IMG SRC="./RADIATION/crmplatt.gif"></CENTER>'

;printf, 2, "<SCRIPT> setTimeout('location.reload()',1000000) </SCRIPT>"


;printf, 2, '</html>'
;close, 2



END
