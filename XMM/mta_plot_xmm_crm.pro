PRO MTA_PLOT_XMM_CRM,XMIN,XMAX,PLOTX=plotx

;-----------------------------------------------------------------------
; plot xmm and cxo crmregion, called by mta_plot_xmm.pro
;
; specify exact bounds of x axis (in days since 1/1/1998) to match
;  xmm_rad plot
; 18.aug2004 bds
;
; last updated: Feb 29, 2016    ti
;
;-----------------------------------------------------------------------
;
;--- set colors and chracters
;
loadct, 39          ; color table setting (rainbow with white)
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

regcolor   = [0,150,100,190]
;
;--- set xmargin
;
xleft      = 15 
xright     = 1
;
;--- figure out time ranges and labels
;
t_arch     = fix(xmax-xmin)

print,xmin,xmax

doyticks   = indgen(t_arch) + floor(min(xmin))
nticks     = n_elements(doyticks)
xticklab   = strcompress(string(doyticks+1),/remove_all)

;
;--- XMM Plot starts
;
crmfile = "crmreg_xmm.dat"
readcol, crmfile, Csec, R, Xgsm, Ygsm, Zgsm, crmreg, $
         format='L,F,F,F,F,I',skipline=5

;
;--- convert time into day of the year
;
;time   = (Csec/60./60./24.)-2190.0-366.-365.-365.-365.-366.-(6*365.) ; 2010 days
time     = (Csec/60./60./24.)-2190.0-366.-365.-365.-365.-366.-365. ; 2010 days
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
time     = time - (365 * dyear + ladd) 

s      = sort(time)  ; sort just in case
time   = time(s)
print, time;
crmreg = crmreg(s)

plot,[0,0],[0,0], background=back_color, color=grid_color, $
     xstyle=1, ystyle=1, xrange=[xmin,xmax], yrange=[0,1], /nodata, $
     charsize=csize, ymargin=[-6,17], xmargin=[xleft,xright], $
     ytitle="XMM", $
     xticks=nticks-1, xtickv=doyticks, $
     xtickformat='no_axis_labels', $
     ytickformat='no_axis_labels'

b = where(time ge xmin and time le xmax,bnum)

if (bnum gt 0) then begin
    tstart=time(min(b))
    crmstart=crmreg(min(b))
    maxi=max(b)
    i=min(b)

    while (i lt maxi) do begin

        while (crmreg(i) eq crmstart) do begin
            i=i+1

            if (i eq maxi) then crmreg(i)=0 ; trigger last region and end 

        endwhile ; while (crmreg(i) eq crmstart) do begin

        polyfill, [tstart, tstart, time(i),time(i)], [0,1,1,0], $
                        color=regcolor(crmstart)
        tstart=time(i)
        crmstart=crmreg(i)
    endwhile ; while (i lt n_elements(crmreg)-1) do begin
endif ; if (bnum gt 0) then begin

;
;--- CXO plot start here
;

crmfile = "crmreg_cxo.dat"
readcol, crmfile, sec, R, Xgsm, Ygsm, Zgsm, crmreg, $
         format='L,F,F,F,F,I',skipline=5
;
;--- convert time into day of the year
;
;;;;time = (sec/60./60./24.)-2190.0-366.-365.-365.-365.-366.-(6*365.) ; 2010 days
time     = (sec/60./60./24.)-2190.0-366.-365.-365.-365.-366.-365. ; 2010 days
;
;--- convert jday to this year's yday
;
atime    = systime()
atemp    = strsplit(atime,/extract)
dyear    = fix(atemp[4]) - 2010             ; ---- how many years from 2010?
ladd     = dyear /4                         ; ---- how many leap year between 2010 and this year?
time     = time - (365 * dyear + ladd) - 1
s    = sort(time)  ; sort just in case
time = time(s)
;
;--- find this year for x axis label
;
sdate = systime()
stemp = strsplit(sdate,  /EXTRACT)
tyear = fix(stemp[4])
syear = string(tyear, format='(i4)')
xline = "DOY (" + syear + ")"

plot,[0,0], [0,0], background=back_color, color=grid_color, $
    xstyle=1, ystyle=1, xrange=[xmin,xmax], yrange=[0,1], /nodata, $
    charsize=csize, ymargin=[4,7], xmargin=[xleft,xright], $
    xticks=nticks-1, xtickv=doyticks, ytitle="CXO", $
    xtickname=xticklab, xminor=12, $
    xtitle=xline, $
    ytickformat='no_axis_labels'

b = where(time ge xmin and time le xmax, bnum)

if (bnum gt 0) then begin
    tstart=time(min(b))
    crmstart=crmreg(min(b))
    maxi=max(b)
    i=min(b)

    while (i lt maxi) do begin

        while (crmreg(i) eq crmstart) do begin
            i=i+1

            if (i eq maxi) then crmreg(i)=0 ; trigger last region and end 

        endwhile ; while (crmreg(i) eq crmstart) do begin

        polyfill, [tstart, tstart, time(i),time(i)], [0,1,1,0], $
                  color=regcolor(crmstart)
        tstart   = time(i)
        crmstart = crmreg(i)

    endwhile ; while (i lt n_elements(crmreg)-1) do begin

endif ; if (bnum gt 0) then begin

xyouts,0.3, 0.19, "Solar Wind",    color=regcolor(1), charsize=1, /norm, align=0.5
xyouts,0.5, 0.19, "Magnetosheath", color=regcolor(2), charsize=1, /norm, align=0.5
xyouts,0.7, 0.19, "Magnetosphere", color=regcolor(3), charsize=1, /norm, align=0.5

;write_gif,'/data/mta4/www/RADIATION/XMM/mta_xmm_plot_crm.gif',tvrd()

end
