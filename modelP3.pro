; IDL Version 5.3 (sunos sparc)
; Journal File for mta@rhodes
; Working directory: /data/mta4/space_weather
; Date: Wed Nov 12 13:50:20 2003
 
rdfloat,'/dta/mta4/www/DAILY/mta_rad',y,m,d,h,jd,s,es,e1,e4,ps,p2,p3, $
p5,p6,p7,a
; % NUMLINES: ERROR - Unable to open file /dta/mta4/www/DAILY/mta_rad
rdfloat,'/data/mta4/www/DAILY/mta_rad',y,m,d,h,jd,s,es,e1,e4,ps,p2,p3, $
p5,p6,p7,a
; % NUMLINES: ERROR - Unable to open file /data/mta4/www/DAILY/mta_rad
rdfloat,'/data/mta4/www/DAILY/mta_rad/ace_data.txt',y,m,d,h,jd,s,es,e1,e4,$
ps,p2,p3,p5,p6,p7,a
b=where(ps eq 0)
b=where(ps eq 0 and jd lt 52930)
plot,p5(b),p3(b),psym=3,ystyle=1,xstyle=1
print,min(p3(b))
;     -100000.
b=where(ps eq 0 and jd lt 52930 and p3 gt 0 and p5 gt 0)
plot,p5(b),p3(b),psym=3,ystyle=1,xstyle=1
fit=linfit(p5(b),p3(b))
print,fit
;      608.649      4.72467
b=where(ps eq 0 and jd lt 52930 and p3 gt 0 and p6 gt 0)
plot,p6(b),p3(b),psym=3,ystyle=1,xstyle=1
fit=linfit(p6(b),p3(b))
print,fit
;      1462.62      9.46401
plot,p3(b)/p6(b),p6(b)/p7(b),psym=3
; % Program caused arithmetic error: Floating divide by 0
b=where(ps eq 0 and jd lt 52930 and p3 gt 0 and p6 gt 0 and p7 gt 0)
plot,p3(b)/p6(b),p6(b)/p7(b),psym=3
plot,p3(b)/p6(b),p6(b)/p7(b),psym=3,xstyle=1,xrange=[0,1000]
plot,p3(b)/p6(b),p6(b)/p7(b),psym=3,xstyle=1,xrange=[0,400], $
ystyle=1,yrange=[0,20]
; IDL Version 5.3 (sunos sparc)
; Journal File for mta@rhodes
; Working directory: /data/mta4/space_weather
; Date: Wed Nov 12 14:49:15 2003
 
x=indgen(2)*1.2e5
plot,p6(b),p3(b),psym=3,ystyle=1,xstyle=1,xrange=[0,1e4],yrange=[0,5e4]
oplot,x,x*9.47
print,moment(p7(b)/p6(b))
;     0.374259     0.204878      405.314      188893.
plot,p7(b),p6(b)
plot,p7(b),p6(b),psym=3
plot,p3(b),(p6(b)*36)*((p7(b)/p6(b))/2.5)/p3(b),psym=3
plot,p3(b),(p6(b)*36)*((p7(b)/p6(b))/2.5)/p3(b),psym=3,yrange=[0,20]
plot,p3(b),(p6(b)*36)*((p7(b)/p6(b))/2.5)/p3(b),psym=3,yrange=[0,5]
b=where(ps eq 0 and jd lt 52930 and p3 gt 0 and p6 gt 0 and p7 gt 0 and $
jd gt 52750)
plot,p3(b),(p6(b)*36)*((p7(b)/p6(b))/2.5)/p3(b),psym=3,yrange=[0,5]
plot,jd(b),p3(b),psym=3
plot,jd(b),p3(b),psym=3,/ylog
b=where(ps eq 0 and jd lt 52930 and p3 gt 0 and p6 gt 0 and p7 gt 0 and $
jd gt 52920)
plot,jd(b),p3(b),psym=3,/ylog
oplot,jd(b),p6(b),psym=5
oplot,jd(b),p7(b),psym=7
b=where(ps eq 0 and jd lt 52930 and p3 gt 0 and $
jd gt 52920)
plot,jd(b),p3(b),psym=3,/ylog
plot,jd(b),p3(b),psym=3,/ylog,yrange=[0.001,1000]
b=where(ps eq 0 and jd lt 52930 and $
jd gt 52920)
print,p3(b)
print,p6(b)
b=where(ps eq 0 and jd lt 52930 and p3 gt 0.0 and $
jd gt 52920)
plot,jd(b),p3(b),psym=3,/ylog,yrange=[0.001,1000]
journsl
; IDL Version 5.3 (sunos sparc)
; Journal File for mta@rhodes
; Working directory: /data/mta4/space_weather
; Date: Wed Nov 12 15:06:57 2003
 
plot,p3(b),(p6(b)*36)*((p6(b)/p7(b))/2.5)/p3(b),psym=3,yrange=[0,5]
; % Program caused arithmetic error: Floating divide by 0
plot,p3(b),(p6(b)*36)*((p6(b)/p7(b))/2.5)/p3(b),psym=3,yrange=[0,5], $
xrange=[0,5]
; % Program caused arithmetic error: Floating divide by 0
xrange=[0,50]
plot,p3(b),(p6(b)*36)*((p6(b)/p7(b))/2.5)/p3(b),psym=3,yrange=[0,5], $
xrange=[0,50]
; % Program caused arithmetic error: Floating divide by 0
b=where(ps eq 0 and jd lt 52930 and p3 gt 0 and p6 gt 0 and p7 gt 0)
plot,p3(b),p6(b)/p7(b),psym=3
plot,p3(b),p6(b)/p7(b),psym=3,xrange=[0,2e5]
plot,p3(b),p6(b)/p7(b),psym=3,xrange=[0,1e5]
print,moment(p6(b)/p7(b))
;      3.12503      2.40740      4.92528      55.6052
plot,p3(b)/p6(b),p6(b)/p7(b),psym=3,xrange=[0,1e5]
plot,p3(b)/p6(b),p6(b)/p7(b),psym=3
plot,p3(b)/p6(b),p6(b)/p7(b),psym=3,xrange=[0,5e3]
plot,p3(b)/p6(b),p6(b)/p7(b),psym=3,xrange=[0,1000]
plot,p3(b)/p6(b),p6(b)/p7(b),psym=3,xrange=[0,200]
plot,p3(b),(p6(b)*36)*((p7(b)/p6(b))/2.5)/p3(b),psym=3,yrange=[0,5]
plot,p3(b),(p6(b)*36)*((p6(b)/p7(b))/2.5)/p3(b),psym=3,yrange=[0,5]
print,moment(p6(b)*36)*((p6(b)/p7(b))/2.5)/p3(b))
; % Syntax error.
print,moment((p6(b)*36)*((p6(b)/p7(b))/2.5)/p3(b))
;      2.57758      927.111      474.017      232849.
print,moment((p6(b)*10)*((p6(b)/p7(b))/2.5)/p3(b))
;     0.716005      71.5345      474.035      232861.
print,moment((p6(b)*15)*((p6(b)/p7(b))/2.5)/p3(b))
;      1.07399      160.954      474.028      232856.
print,moment((p6(b)*15)*((p6(b)/p7(b))/2.4)/p3(b))
;      1.11875      174.647      474.026      232855.
print,moment((p6(b)*15)*((p6(b)/p7(b))/2.6)/p3(b))
;      1.03269      148.810      474.033      232860.
print,moment((p6(b)*15)*((p6(b)/p7(b))/2.7)/p3(b))
;     0.994441      137.991      474.035      232861.
print,moment((p6(b)*15)*((p6(b)/p7(b))/2.8)/p3(b))
;     0.958928      128.314      474.013      232847.
print,moment((p6(b)*15)*((p6(b)/p7(b))/2.75)/p3(b))
;     0.976367      133.023      474.013      232846.
print,moment((p6(b)*15)*((p6(b)/p7(b))/2.65)/p3(b))
;      1.01320      143.247      474.035      232861.
print,moment((p6(b)*15)*((p6(b)/p7(b))/2.72)/p3(b))
;     0.987128      135.969      474.037      232862.
print,moment((p6(b)*15)*((p6(b)/p7(b))/2.68)/p3(b))
;      1.00187      140.058      474.035      232861.
print,moment((p6(b)*16)*((p6(b)/p7(b))/2.7)/p3(b))
;      1.06074      157.004      474.030      232858.
print,moment((p6(b)*14)*((p6(b)/p7(b))/2.7)/p3(b))
;     0.928144      120.209      474.014      232847.
plot,p3(b),((p6(b)*15)*((p6(b)/p7(b))/2.68)/p3(b)),psym=3
plot,p3(b),((p6(b)*15)*((p6(b)/p7(b))/2.68)/p3(b)),psym=3,yrange=[-1,5]
plot,p3(b),((p6(b)*15)*p3(b)-((p6(b)/p7(b))/2.68)),psym=3,yrange=[-1,5]
plot,p3(b),((p6(b)*15)*p3(b)-((p6(b)/p7(b))/2.68)),psym=3
plot,p3(b),((p6(b)*15)*(p3(b)-((p6(b)/p7(b))/2.68)))/p3(b),psym=3
b=where(ps eq 0 and jd lt 52930 and p3 gt 0 and p6 gt 0 and p7 gt 0 and $
jd gt 52910)
plot,jd(b)+s(b)/86400,p3(b),psym=3
plot,jd(b)+s(b)/86400,p3(b),psym=3,/ylog
plot,jd(b)+s(b),(p6(b)/p7(b))/2.7
plot,jd(b)+s(b)/86400,p3(b),psym=3,/ylog
oplot,jd(b)+s(b),(p6(b)/p7(b))/2.7,psym=1
oplot,jd(b)+s(b),p6(b)*15*(p6(b)/p7(b))/2.7,psym=1
oplot,jd(b)+s(b),p6(b)*15*(p6(b)/p7(b))/2.7
plot,jd(b)+s(b)/86400,p3(b),psym=3,/ylog
plot,jd(b)+s(b),(p6(b)/p7(b))/2.7
plot,jd(b)+s(b)/86400,p3(b),psym=3,/ylog
oplot,jd(b)+s(b),p6(b)*15*(p6(b)/p7(b))/2.7
oplot,jd(b)+s(b),p6(b)*15.*(p6(b)/p7(b))/2.7
plot,jd(b)+s(b)/86400,p3(b),psym=3,/ylog
oplot,jd(b)+s(b)/86400.,p6(b)*15.*(p6(b)/p7(b))/2.7
oplot,jd(b)+s(b)/86400.,p6(b)*36.
window,1
plot,jd(b)+s(b)/86400.,p3(b)-p6(b)*36.
plot,jd(b)+s(b)/86400.,p6(b)
plot,jd(b)+s(b)/86400.,p7(b)
plot,jd(b)+s(b)/86400.,p6(b),psym=1
plot,jd(b)+s(b)/86400.,p7(b)
oplot,jd(b)+s(b)/86400.,p6(b),psym=1
oplot,jd(b)+s(b)/86400.,p6(b)/p7(b),psym=1
plot,jd(b)+s(b)/86400.,p6(b)/p7(b),psym=1
print,linfit(15*(p6(b)/p7(b)),p3(b)/p6(b))
;      132.048    -0.884202
plot,15*(p6(b)/p7(b)),p3(b)/p6(b),psym=3
plot,15*(p6(b)/p7(b)),p3(b)/p6(b),psym=3,yrange=[0,100]
print,linfit((p6(b)/p7(b))/-0.8842,p3(b)/p6(b))
; % Syntax error.
print,linfit((p6(b)/p7(b))/(-0.8842),p3(b)/p6(b))
;      132.048      11.7272
print,linfit(36*(p6(b)/p7(b)),p3(b)/p6(b))
;      132.048    -0.368417
print,linfit(96*(p6(b)/p7(b)),p3(b)/p6(b))
;      132.048    -0.138156
print,linfit(11.72*(p6(b)/p7(b)),p3(b)/p6(b))
;      132.048     -1.13165
print,linfit((p6(b)/p7(b))/(2.5),p3(b)/p6(b))
;      132.049     -33.1576
b=where(ps eq 0 and jd lt 52930 and p3 gt 0 and p6 gt 0 and p7 gt 0 and $
jd gt 52910 and p6/p7 lt 100)
; % Program caused arithmetic error: Floating divide by 0
; % Program caused arithmetic error: Floating illegal operand
print,linfit((p6(b)/p7(b))/(2.5),p3(b)/p6(b))
;      132.049     -33.1576
b=where(ps eq 0 and jd lt 52930 and p3 gt 0 and p6 gt 0 and p7 gt 0 and $
jd gt 52910 and p6/p7 lt 10)
; % Program caused arithmetic error: Floating divide by 0
; % Program caused arithmetic error: Floating illegal operand
print,linfit((p6(b)/p7(b))/(2.5),p3(b)/p6(b))
;      159.169     -55.7799
plot,15*(p6(b)/p7(b)),p3(b)/p6(b),psym=3,yrange=[0,100]
