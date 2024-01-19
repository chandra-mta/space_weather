rdfloat,'/data/mta4/www/DAILY/mta_rad/ace_data.txt',y,m,d,h,jd,s,es,e1,e4,$
  ps,p2,p3,p5,p6,p7,a
b=where(p6 gt 0 and p7 gt 0 and p3 gt 0 and jd lt 52912)
print,moment(p3(b)/p6(b))
;      591.814  8.39189e+07      20.9443      489.774
hist=histogram(p3(b)/p6(b),binsize=2,min=0,max=1000)
plot,indgen(n_elements(hist))*2+1,hist,psym=10,xrange=[0,50], $
  xtitle='p3/p6',ytitle='N',color=0,backg=255

b=where(p6 gt 0 and p7 gt 0 and p3 gt 0 and jd ge 52640 and jd lt 52912)
print,moment(p3(b)/p6(b))
hist=histogram(p3(b)/p6(b),binsize=2,min=0,max=1000)
oplot,indgen(n_elements(hist))*2+1,hist,psym=10,linestyle=0,color=0

b=where(p6 gt 0 and p7 gt 0 and p3 gt 0 and jd ge 52275 and jd lt 52640)
print,moment(p3(b)/p6(b))
hist=histogram(p3(b)/p6(b),binsize=2,min=0,max=1000)
oplot,indgen(n_elements(hist))*2+1,hist,psym=10,linestyle=1,color=0

b=where(p6 gt 0 and p7 gt 0 and p3 gt 0 and jd ge 51910 and jd lt 52275)
print,moment(p3(b)/p6(b))
hist=histogram(p3(b)/p6(b),binsize=2,min=0,max=1000)
oplot,indgen(n_elements(hist))*2+1,hist,psym=10,linestyle=2,color=0
write_gif,'xp3_p6_hist.gif',tvrd()

b=where(p6 gt 0 and p7 gt 0 and p3 gt 0 and jd lt 52912)
hist=histogram(p6(b)/p7(b),binsize=0.5,min=0,max=1000)
plot,indgen(n_elements(hist))*0.5+0.25,hist,psym=10,xrange=[0,10], $
  xtitle='p6/p7',ytitle='N',color=0,backg=255

b=where(p6 gt 0 and p7 gt 0 and p3 gt 0 and jd ge 52640 and jd lt 52912)
hist=histogram(p6(b)/p7(b),binsize=0.5,min=0,max=1000)
oplot,indgen(n_elements(hist))*0.5+0.25,hist,psym=10,linestyle=0,color=0

b=where(p6 gt 0 and p7 gt 0 and p3 gt 0 and jd ge 52275 and jd lt 52640)
hist=histogram(p6(b)/p7(b),binsize=0.5,min=0,max=1000)
oplot,indgen(n_elements(hist))*0.5+0.25,hist,psym=10,linestyle=1,color=0

b=where(p6 gt 0 and p7 gt 0 and p3 gt 0 and jd ge 51910 and jd lt 52275)
hist=histogram(p6(b)/p7(b),binsize=0.5,min=0,max=1000)
oplot,indgen(n_elements(hist))*0.5+0.25,hist,psym=10,linestyle=2,color=0
write_gif,'xp6_p7_hist.gif',tvrd()

b=where(p6 gt 0 and p7 gt 0 and p3 gt 0 and jd lt 52912)
print,linfit(p6(b)*(p6(b)/p7(b))/2.7,p3(b))
plot,p6(b)*(p6(b)/p7(b))/2.7,p3(b),psym=3,xrange=[0,2e4], $
xtitle="p6*(p6/p7)/2.7",ytitle="p3",color=0,backg=255
b=where(p6 gt 0 and p7 gt 0 and p3 gt 0 and jd ge 52640 and jd lt 52912)
print,linfit(p6(b)*(p6(b)/p7(b))/2.7,p3(b))
oplot,p6(b)*(p6(b)/p7(b))/2.7,p3(b),psym=1,color=0       
b=where(p6 gt 0 and p7 gt 0 and p3 gt 0 and jd ge 52275 and jd lt 52640)
print,linfit(p6(b)*(p6(b)/p7(b))/2.7,p3(b))
oplot,p6(b)*(p6(b)/p7(b))/2.7,p3(b),psym=5,color=0
b=where(p6 gt 0 and p7 gt 0 and p3 gt 0 and jd ge 51910 and jd lt 52275)
print,linfit(p6(b)*(p6(b)/p7(b))/2.7,p3(b))
oplot,p6(b)*(p6(b)/p7(b))/2.7,p3(b),psym=7,color=0
write_gif,'xp6_p7_2_p3.gif',tvrd()

b=where(p6 gt 0 and p7 gt 0 and p3 gt 0 and jd ge 52882 and jd lt 52912)
plot,jd(b)+(s(b)/86400.0),p6(b),psym=3,color=0,backgr=255,yrange=[0.1,1e4],$
  /ylog,xrange=[52882,52912],ystyle=1,xstyle=1, $
  xtitle="time (JD)",ytitle="flux",title="sept 2003"
oplot,jd(b)+(s(b)/86400.0),p7(b),psym=3,color=0
oplot,jd(b)+(s(b)/86400.0),p3(b),psym=3,color=0
oplot,jd(b)+(s(b)/86400.0),p6(b)*(p6(b)/p7(b))*2.7*12.0,psym=7,color=0
oplot,jd(b)+(s(b)/86400.0),p6(b)*36.0,psym=1,color=0
write_gif,'xp6_p7_2_p3_comp.gif',tvrd()

plot,jd(b)+(s(b)/86400.0),p3(b)-(p6(b)*(p6(b)/p7(b))/2.7*12.0), $
  psym=7,color=0, $
  backg=255,ystyle=1,xstyle=1,$
  xtitle="time (JD)",ytitle="res. flux",title="sept 2003 residuals"
oplot,jd(b)+(s(b)/86400.0),p3(b)-(p6(b)*36.0),psym=1,color=0
write_gif,'xp6_p7_2_p3_res.gif',tvrd()

b=where(p6 gt 0 and p7 gt 0 and p3 gt 0 and jd ge 52882 and jd lt 52912)
p3_mod=p6_p7_2_p3(p6(b),p7(b))
plot,jd(b)+(s(b)/86400.0),p6(b),psym=3,color=0,backgr=255,yrange=[0.1,1e4],$
  /ylog,xrange=[52882,52912],ystyle=1,xstyle=1, $
  xtitle="time (JD)",ytitle="flux",title="sept 2003"
oplot,jd(b)+(s(b)/86400.0),p7(b),psym=3,color=0
oplot,jd(b)+(s(b)/86400.0),p3(b),psym=3,color=0
oplot,jd(b)+(s(b)/86400.0),p3_mod,psym=7,color=0
write_gif,'xp6_p7_2_p3_mod.gif',tvrd()

