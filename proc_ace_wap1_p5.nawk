BEGIN{ 
  time2   = -1
  E38m  =10000000.
  E175m  =10000000.
  P56m  =10000000.
  P130m  =10000000.
  P337m   =10000000.
  P761m  =10000000.
  P1073m  =10000000.

  i=0.0
  ie=0.0

fmt1="%4d %2d %2d %4d <br/> %11.3f <br/>\n"

fmt2="%7s <br/> %14.4e <br/>\n"

print "<?xml version='1.0'?>"
print "<!DOCTYPE wml PUBLIC '-//WAPFORUM//DTD WML 1.1//EN' 'http://www.wapforum.org/DTD/wml_1.1.xml'>"

print "<wml>"
print "<card id='init' newcontext='true'>"
print "<p>"
print "Recent ACE<br/>"

P6_P3_scale=36.
P5_P3_scale=7.
P6_P3=-100000
P5_P3=-100000
} # BEGIN{ 

{ #loop
  if ($10 == 0){ 
    P6_P3=$14*P6_P3_scale
    P5_P3=$13*P5_P3_scale
    i += 1.
    year += $1
    month += $2
    day += $3
    time += $4
    P56  +=P6_P3
    P130  +=P5_P3
    P337    +=$13
    P761  +=$14
    P1073   +=$15

#find minima (maxima for time)
    if ($4 > time2)   time2 = $4
    #P2#if ($11 < P56m)  P56m = $11
    if (P6_P3 < P56m)  P56m = P6_P3
    #P3#if ($12 < P130m)  P130m = $12
    if (P5_P3 < P130m)  P130m = P5_P3
    if ($13 < P337m)  P337m = $13
    if ($14 < P761m)  P761m = $14
    if ($15 < P1073m)  P1073m = $15
    } # if ($10 == 0){ 

  if ($7 == 0){ 
    ie += 1.
    E38  +=$8
    E175  +=$9

#find minima (maxima for time)
    if ($8 < E38m)  E38m = $8
    if ($9 < E175m)  E175m = $9

    } # if ($7 == 0){ 

} # { #loop

END  {

if (E175m != 10000000.){
  P337a=P337 / i 
  P761a=P761 / i 

  if (P337a/P761a < 7 && P337a/P761a > 1) { # trust P5
    print "*scaled from P5<br/>"
  } else { # trust P6
    P130=P56
    P130m=P56m
    print "*scaled from P6<br/>"
  } # if (P337a/P761a <7) { # trust P5
  yeara = year/i
  montha = month/i
  daya = day/i

  P130a=P130 / i 
  P130f=P130a * 7200.  #* 0.084
  P130m=P130m / 1. 

  print "2 hour Flux<br/>"
  print "112-187keV*<br/>"

  printf(fmt2, "AVERAGE", P130a)
  printf(fmt2, "MINIMUM", P130m)
  printf(fmt2, "FLUENCE", P130f)

}  # if (E175m != 10000000.){
  else print " No Valid data for last 2 hours<br/>"
print "p/cm2-s-sr-MeV<br/>"
print "<br/><a href='sot.wml'>SOT Home</a><br/>"
} # END
