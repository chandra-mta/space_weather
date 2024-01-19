rdfloat,'/data/mta4/www/DAILY/mta_rad/ace_data.txt',y,m,d,h,jd,s,es,e1,e4,$
  ps,p2,p3,p5,p6,p7,a

b=where(jd gt 52822 and jd lt 52912 and p3 gt 0 and p6 gt 0 and p7 gt 0)
jd=jd(b)
p3=p3(b)
p6=p6(b)
p7=p7(b)
