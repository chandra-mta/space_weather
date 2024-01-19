FUNCTION P6_P7_2_P3, p6_in, p7_in

p3_out=lonarr(n_elements(p6_in))
rdfloat,'/data/mta4/www/DAILY/mta_rad/ace_data.txt',y,m,d,h,jd,s,es,e1,e4,$
  ps,p2,p3,p5,p6,p7,a

b=where(jd gt 52882 and jd lt 52912 and p3 gt 0 and p6 gt 0 and p7 gt 0)
jd=jd(b)
p3=p3(b)
p6=p6(b)
p7=p7(b)

p6_p7_in=p6_in/p7_in
p6_p7=p6/p7
for i=0,n_elements(p6_in)-1 do begin
  k=0
  range_fact=0.01
  while (k eq 0) do begin
    range_fact=range_fact*2.0
    p6_range=p6_in(i)*range_fact
    p7_range=p7_in(i)*range_fact
    p6_p7_range=p6_p7_in(i)*range_fact
    b=where(abs(p6-p6_in) le p6_range and $
            abs(p6_p7-p6_p7_in) le p6_p7_range,num)
    print,num
    if (num gt 1) then k = 1
  endwhile ; while (k eq 0) do begin
  m=moment(p3(b))
  p3_out(i)=m(0)
endfor ;for i=0,n_elements(p6_in)-1 do begin
return, p3_out
end
