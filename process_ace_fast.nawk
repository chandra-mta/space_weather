# 6 nov 2003 bds
#  this version was used while ACE P3 channel was sick
#    uses P5*scale factor, unless P5 looks sick, then use P6*scaler
# 04 feb 2004 bds
#  P2 and P3 added back in when ACE is fixed
#   alert on P3 as before and keep P6 scaled alert for now
# 07 Jun 2012 - add filter for "bogus" ACE data
BEGIN{ 
  time2   = -1
  E38m  =10000000.
  E175m  =10000000.
  P56m  =10000000.
  P130m  =10000000.
  P337m   =10000000.
  P761m  =10000000.
  P1073m  =10000000.
  P5_P3m  =10000000.
  P6_P3m  =10000000.
  P7_P3m  =10000000.
  getline < "start_ace"
  split($0, last_vals)
  p2_start  =last_vals[1]
  p3_start  =last_vals[2]
  p5_start  =last_vals[3]
  p6_start  =last_vals[4]
  p7_start  =last_vals[5]
  p2_last  =last_vals[1]
  p3_last  =last_vals[2]
  p5_last  =last_vals[3]
  p6_last  =last_vals[4]
  p7_last  =last_vals[5]
  P56a  =0.
  P130a  =0.
  P337a   =0.
  P761a  =0.
  P1073a  =0.
  P5_P3a  =0.
  P6_P3a  =0.
  P7_P3a  =0.

  i=0.0
  i5=0.0
  i6=0.0
  i7=0.0
  ie=0.0

  fmt1="%4d %2d %2d %4d %11.3f %11.3f %11.3f %11.3f %11.3f %11.3f %11.3f %11.3f %11.3f\n"

  fmt2="%7s %11.3f %11.3f %11.3f %11.3f %11.3f %11.3f %11.3f %11.3f %11.3f\n"
  fmt3="%7s %11.4e %11.4e %11.4e %11.4e %11.4e %11.4e %11.4e %11.4e %11.4e\n"
  fmt4="%7s %11s %11.3f %11s %11.3f %11s %11.3f %11s %11.3f \n"

  print "                                        Quicklook ACE observations"
  print "                                 Differential Flux particles/cm2-s-ster-MeV"
  print " "
  print " UT Date   Time    --- Electron keV ---     ---------------------------------- Protons keV -------------------------------"
  #print "                     DE1         DE4     P3ScaledP6   P3scaledP5      P5         FP6p         P7"
  print "                     DE1          DE4         P2          P3       P3ScaledP5  P3scaledP6      P5          FP6p         P7"
  #print "  YR MO DA HHMM     38-53      175-315    65-112     112-187     112-187*    112-187**    310-580    761-1220   1060-1910"
  print "  YR DOY HH MM     38-53       175-315     47-68       115-195     112-187*    112-187**    310-580     761-1220  1060-1910"

n=1

}  #BEGIN , only do once

{  # start loop, do for each record
P5_P3_scale=7. # scale P5 to P3 values, while P3 is broke
P6_P3_scale=36. # scale P6 to P3 values, while P3 is broke
P7_P3_scale=110. # scale P7 to P3 values, while P3 is broke

#print $1" "$2" "$3" "$4" "$5" "$6" "$7"  "$8" "$9" "$10" "$11" "$12" "$13" "$14" "$15" "$16
#P3#printf(fmt1, $1, $2, $3, $4, $8,$9,$11,$12,$13,$14,$15)

# initialize calculated values (in case $10 !=0, missing data)
P5_P3_scale=7. # scale P5 to P3 values, while P3 is broke
P6_P3_scale=36. # scale P6 to P3 values, while P3 is broke
P7_P3_scale=110. # scale P7 to P3 values, while P3 is broke

P5_P3_scaled=-100000.000 
P6_P3_scaled=-100000.000 
P7_P3_scaled=-100000.000 

if ($10 > 0){  # is data still valid?
  i += 1.
  year += $1
  #month += $2
  #day += $3
  doy += $2
  #time += print($4 $5)
  P56  +=$8
  P130  +=$9
  P5_P3_scaled=$10*P5_P3_scale
  P6_P3_scaled=$11*P6_P3_scale
  P7_P3_scaled=$12*P7_P3_scale

#find minima (maxima for time)
  if ($4 > time2)   time2 = $4    #  CHANGE TIME
  if ($8 < P56m)  P56m = $8
  if ($9 < P130m)  P130m = $9

} #if ($10 == 0){ 

printf(fmt1, $1, $2, $3, $4, $6,$7,$8,$9,P5_P3_scaled,P6_P3_scaled,$10,$11,$12)

  ie += 1.
  E38  +=$6
  E175  +=$7

#find minima (maxima for time)
  if ($6 < E38m)  E38m = $6
  if ($7 < E175m)  E175m = $7

} # end loop, do for each record

END { # do once, at the end
# save last values
system("echo " p2_start" "p3_start" "p5_start" "p6_start" "p7_start "> start_ace")

#Calculate averages
# old way if (E175m != 10000000.){
if (i > 0 && ie > 0){
  yeara = year/i
  montha = month/i
  daya = day/i

  E38a    =E38 / ie   
  E175a  =E175 / ie 
  P56a    =P56 / i 
  P130a   =P130 / i

#calculate 2-hour fluence
  E38f    =E38a * 7200.   #* 0.015
  E175f  =E175a * 7200.  #* 0.140
  P56f    =P56a *  7200.  #* 0.022
  P130f   =P130a * 7200.  #* 0.084
  P337f   =P337a * 7200.  #* 0.257
  P761f   =P761a * 7200.  #* 0.459
  P1073f  =P1073a * 7200. #* 0.729
  P5_P3f  =P5_P3a * 7200. #
  P6_P3f  =P6_P3a * 7200. #
  P7_P3f  =P7_P3a * 7200. #

#calculate- minimum
  E38m    =E38m / 1.   
  E175m  =E175m / 1. 
  P56m   =P56m/ 1. 
  P130m   =P130m / 1. 
  P337m   =P337m / 1. 
  P761m   =P761m / 1. 
  P1073m  =P1073m / 1.

#Calculate Spectral indcies:
  P3_P5 = P130a/P337a
  P3_P6 = P130a/P761a
  P5_P6 = P337a/P761a
  P6_P7 = P761a/P1073a
  P5_P7 = P337a/P1073a

#VIOLATION CHECKS:

  print " "
  print " "
  print "                        2 hour  Real-time Differential Electron and Proton Flux"
  #print "                                 Differential Flux particles/cm2-s-ster-MeV"
  print " "
  print "                   --- Electron keV ---     ----------------------------------- Protons keV ---------------------------------"
  #print "                   DE1         DE4        P3scaledP6      P3scaledP5         P5            FP6p           P7"
  print "                     DE1          DE4         P2          P3        P3ScaledP5   P3scaledP6     P5        FP6p         P7"
  #print "                    38-53      175-315    65-112     112-187       112-187*     112-187**    310-580    761-1220   1060-1910"
  print "                    38-53       175-315     47-68       115-195      112-187*    112-187**    310-580    761-1220   1060-1910"

  print " "
  #printf(fmt2, "AVERAGE", E38a,E175a,P56a,P130a,P337a,P761a,P1073a)
  #printf(fmt2, "MINIMUM", E38m,E175m,P56m,P130m,P337m,P761m,P1073m)
  #printf(fmt3, "FLUENCE", E38f,E175f,P56f,P130f,P337f,P761f,P1073f)
  printf(fmt2, "AVERAGE        ", E38a,E175a,P56a,P130a,P5_P3a,P6_P3a,P337a,P761a,P1073a)
  if (P337m > P337a) P337m=0.  # hack, if all P5 is bad
  printf(fmt2, "MINIMUM        ", E38m,E175m,P56m,P130m,P5_P3m,P6_P3m,P337m,P761m,P1073m)
  printf(fmt3, "FLUENCE        ", E38f,E175f,P56f,P130f,P5_P3f,P6_P3f,P337f,P761f,P1073f)
  print " "
  printf(fmt4, "SPECTRA        ","P3/P5",P3_P5,"P3/P6",P3_P6,"P5/P6",P5_P6,"P6/P7",P6_P7)
  print " "
  fmt_star="%62s %4.1f\n"
  printf(fmt_star, "* This P3 channel is currently scaled from P5 data. P3* = P5 X ", P5_P3_scale)
  printf(fmt_star, "** This P3 channel is currently scaled from P6 data. P3** = P6 X ", P6_P3_scale)
  printf(fmt_star, "*** This P3 channel (not shown) is currently scaled from P7 data. P3*** = P7 X ", P7_P3_scale)

}  # if (E175m != 10000000.){
else {
#  print " No Valid data for last 2 hours"
  #test system("/data/mta4/space_weather/ace_invalid_data.csh")
} #else {
} # END
#
