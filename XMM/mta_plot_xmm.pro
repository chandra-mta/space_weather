FUNCTION NO_AXIS_LABELS, axis, index, value
;--- suppress labelling axis
return, string(" ")
end

PRO MTA_PLOT_XMM, PLOTX=plotx

;--------------------------------------------------------------------
;   upate XMM Plot: mta_xmm_plot.gif
;
;       12. Jul 2003 BDS
;       last updated Feb 29, 2016   ti
;
;--------------------------------------------------------------------
;
;--- first check for license
;---  this is dumb, just crashes before continuing if no license
;
if (NOT have_license()) then return
;
;--- how many days to plot
;
t_arch = 7 
;
;--- read the past data
;
xmm_7d_archive = 'xmm_7day.archive2'
readcol, xmm_7d_archive, $ 
         time_stamp_arc,le0_arc,le1_arc,le2_arc, $
         hes0_arc,hes1_arc,hes2_arc,hec_arc, $
         format='F,F,F,F,F,F,F,F'

t_start = max(long(time_stamp_arc)) ; assume file is sorted
;
;--- read current data
;
xmm_7d_current = 'radmon_02h_curr.dat'
readcol,xmm_7d_current, $ 
        time_stamp,le0,le1,le2,hes0,hes1,hes2,hec, $
        format='A,F,F,F,F,F,F,F'

time_sec_arc = time_stamp_arc
time_sec     = xmm_time(time_stamp)
;
;--- check that updates are current
;
now_sec = systime(/sec) - 8.83613e+08
;
;--- make GMT - seconds from 1998 takes care of GMT
;--- idl jd starts at noon, ace starts at 0Z
;
now_diff = now_sec-max(time_sec)

print,"xmm.archive is ",now_diff/60.0," minutes old"  ;debug

if (now_diff gt 3600.) then begin ; close to 1 hrs w/ no new data
  ;call_brad, "check xmm.archive"  ;debug
endif ; if (now_diff gt 300) then begin 
;
;--- combine and sort and average data
;
t_mark  = 300L*long(round(long(t_start)/300L)) + 300L
max_sec = max(time_sec)

print,t_mark,max_sec

while (t_mark+151 lt max_sec) do begin
    b = where(time_sec gt t_mark-150 and time_sec le t_mark+150,bnum)

    if (bnum gt 1) then begin
        time_stamp_arc = [time_stamp_arc, t_mark]
        m = moment(le0(b))
        le0_arc =  [le0_arc,m(0)]

        m = moment(le1(b))
        le1_arc =  [le1_arc,m(0)]

        m = moment(le2(b))
        le2_arc =  [le2_arc,m(0)]

        m = moment(hes0(b))
        hes0_arc = [hes0_arc,m(0)]

        m = moment(hes1(b))
        hes1_arc = [hes1_arc,m(0)]

        m = moment(hes2(b))
        hes2_arc = [hes2_arc,m(0)]
 
        m = moment(hec(b))
        hec_arc  = [hec_arc,m(0)]
    endif; if (bnum gt 1) then begin

    t_mark = long(t_mark)+300L

endwhile ;while (t_mark+451 lt max_sec) do begin

b = where(time_stamp_arc ge max(time_stamp_arc)-(t_arch+1)*86400.,bnum)

if (bnum gt 0) then begin
    time_stamp_arc = time_stamp_arc(b)

    le0_arc  = le0_arc(b)
    le1_arc  = le1_arc(b)
    le2_arc  = le2_arc(b)
    hes0_arc = hes0_arc(b)
    hes1_arc = hes1_arc(b)
    hes2_arc = hes2_arc(b)
    hec_arc  = hec_arc(b)
endif ; if (bnum gt 0) then begin
;
;---- write updated t_arch-day archive
;
openw,aunit,"xmm_7day.archive2",/get_lun

for i=0,n_elements(time_stamp_arc)-1 do begin 
    printf,aunit, $
        time_stamp_arc(i),le0_arc(i),le1_arc(i),le2_arc(i), $
        hes0_arc(i),hes1_arc(i),hes2_arc(i),hec_arc(i), $
        format='(E14.8,7(" ",F12.3))'
endfor ;for i=0,n_elements(time_stamp)-1 do begin

free_lun,aunit
spawn, "cat xmm_7day.archive2 >> xmm.archive"
spawn, "sort -u -n -k 1,1 xmm.archive -o xmm.archive"
;
;--- print web data
;
openw, hunit, "/data/mta4/www/RADIATION/XMM/xmm_2day.dat",/get_lun
lasti  = n_elements(time_stamp_arc)-1
lastt  = time_stamp_arc(lasti)

;print,cxtime(lastt,'sec','cal') ; debug

startt = lastt - long(1.0*86400.0)          ;--- set how many days to go back
lastt  = lastt + 300                        ;--- allow some wiggle room

while (startt le lastt) do begin
    print,startt,lastt
    maxt=300L
    bnum=0
    while (bnum eq 0) do begin
        print, min(abs(time_stamp_arc-startt)), maxt
        b = where(abs(time_stamp_arc-startt) lt maxt,bnum)

        if (bnum gt 0) then begin
            starti = b(0)
        endif else begin
            maxt = maxt+300L
        endelse ; if (bnum gt 0) then begin

    endwhile ; while (bnum eq 0) do begin

    printf,hunit,cxtime(time_stamp_arc(starti),'sec','cal'), $
           le1_arc(starti),le2_arc(starti), $
           hes1_arc(starti),hes2_arc(starti), hec_arc(starti), $
           format='(A17,5(" ",F12.3))'

    startt = startt + 3600.0 ; set time interval between samples
endwhile ; while (starti le lasti) do begin

free_lun,hunit
;
;--- set-up plotting window
;
xwidth  = 680
yheight = 640

if (keyword_set(plotx)) then begin
    set_plot,'x'
    window,0,xsize=xwidth,ysize=yheight
endif else begin
    set_plot,'z'
    device,set_resolution = [xwidth,yheight]
endelse ; 

!p.multi=[0,1,4,0,0]
;
;---set colors and fonts
;
loadct, 39
back_color = 0      ; black
grid_color = 255    ; white
le1_color  = 255    ; white     
le2_color  = 100    ; light blue
hes1_color = 230    ; red
hes2_color = 215    ; orange
hec_color  = 190    ; yellow

csize      = 2.0
chancsize  = 0.7    ; char size for channel labels
;
;--- set xmargin
;
xleft      = 15 
xright     = 1
;
;--- figure out time ranges and labels
;
jday     = time_stamp_arc/86400.-2190.0-366.-365.-365.-365.-366. -365. ; # days from Jan 1, 2010
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
jday     = jday - (365 * dyear + ladd)

time     = jday - 1.
xmin     = long(max(jday)) - t_arch + 1
xmax     = long(max(jday)) + 1
doyticks = indgen(t_arch)+floor(min(xmin))
nticks   = n_elements(doyticks)
xticklab = strcompress(string(doyticks),/remove_all)
;
;--- just change names, to fit old code
;
le0  = le0_arc
le1  = le1_arc
le2  = le2_arc
hes0 = hes0_arc
hes1 = hes1_arc
hes2 = hes2_arc
hec  = hec_arc

ymin = min(le1(where(le1 gt 0)))
ymax = max([le1_arc,le2,hes1,hes2,hec])

print,ymin,ymax,xmin,xmax ;debugtime
;
;---  temporarily zoom plots 04/01/08 bds
;
ymax = 1000.

plot,time,le2,background=back_color,color=grid_color, $
     xstyle=1,ystyle=1,xrange=[xmin,xmax],yrange=[ymin,ymax],/nodata, $
     charsize=csize,ymargin=[-18,4], xmargin=[xleft,xright], $
     xticks=nticks-1,xtickv=doyticks, /ylog, $
     xtickformat='no_axis_labels',xminor=12
;     
;--- print,"data ",time,le1 ;debugtime
;
oplot, time,le1,  color=le1_color,  psym=3
oplot, time,le2,  color=le2_color,  psym=3
oplot, time,hes1, color=hes1_color, psym=3
oplot, time,hes2, color=hes2_color, psym=3
oplot, time,hec,  color=hec_color,  psym=3

yline=1L

while(yline lt ymax) do begin
    oplot,[xmin,xmax],[yline,yline],color=grid_color,linestyle=2
    yline = yline*10
endwhile ; while(yline lt ymax) do begin

xyouts,xmin,ymax*1.5,"XMM Radiation",/data,charsize=0.9

fit = where(time eq min(time))
fi  = fit(0)

xlabp1 = 0.03                           ;--- xposition for units labels (norm coords)
xlabp2 = 0.055                          ;--- xposition for channel labels (norm coords)

xyouts, xlabp1,0.70,"counts/sec (protons)",orient=90,align=0.5,/norm
xyouts, xlabp2,0.42,'1-1.5 MeV',orient=90,color=le1_color, $
         /norm,charsize=chancsize
xyouts, xlabp2,0.52,'1.5-4.5 MeV',orient=90,color=le2_color, $
       /norm,charsize=chancsize

oplot, time,hes1, psym=3, color=hes1_color
oplot, time,hes2, psym=3, color=hes2_color

yline = 1L

xyouts, xlabp2,0.62,' 8.7-9 MeV',orient=90,color=hes1_color, $
        /norm,charsize=chancsize
xyouts, xlabp2,0.72,' 9-37 MeV',orient=90,color=hes2_color, $
        /norm,charsize=chancsize
xyouts, xlabp2,0.82,' HEC 12.5-100 MeV',orient=90,color=hec_color, $
        /norm,charsize=chancsize

xyouts, 0.99,0.001,'Created: '+systime()+'ET',/norm,align=1.0,charsize=0.8

print,xmin,xmax
mta_plot_xmm_tle,xmin,xmax
mta_plot_xmm_crm,xmin,xmax

write_gif,'/data/mta4/www/RADIATION/XMM/mta_xmm_plot.gif',tvrd()

end
