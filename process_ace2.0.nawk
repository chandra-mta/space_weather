# 6 nov 2003 bds
#  this version was used while ACE P3 channel was sick
#    uses P5*scale factor, unless P5 looks sick, then use P6*scaler
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

  fmt1="%4d %2d %2d %4d %11.3f %11.3f %11.3f %11.3f %11.3f %11.3f %11.3f\n"

  fmt2="%7s %14.3f %14.3f %14.3f %14.3f %14.3f %14.3f %14.3f\n"
  fmt3="%7s %14.4e %14.4e %14.4e %14.4e %14.4e %14.4e %14.4e\n"
  fmt4="%7s %14s %14.3f %14s %14.3f %14s %14.3f \n"

  print "                                        Most recent ACE observations"
  print "                                 Differential Flux particles/cm2-s-ster-MeV"
  print " "
  print " UT Date   Time    --- Electron keV ---     --------------------- Protons keV -------------------"
  #print "                     DE1         DE4     P3ScaledP6   P3scaledP5      P5         FP6p         P7"
  print "                     DE1         DE4     P3ScaledP6   P3scaledP7      P5         FP6p         P7"
  print "  YR MO DA HHMM     38-53      175-315    112-187*     112-187**    310-580    761-1220   1060-1910"
}  #BEGIN , only do once

{  # start loop, do for each record
P5_P3_scale=7. # scale P5 to P3 values, while P3 is broke
P6_P3_scale=36. # scale P6 to P3 values, while P3 is broke
P7_P3_scale=110. # scale P7 to P3 values, while P3 is broke

#print $1" "$2" "$3" "$4" "$5" "$6" "$7"  "$8" "$9" "$10" "$11" "$12" "$13" "$14" "$15" "$16
#P3#printf(fmt1, $1, $2, $3, $4, $8,$9,$11,$12,$13,$14,$15)

# initialize calculated values (in case $10 !=0, missing data)
P5_P3_scaled=-100000.000 
P6_P3_scaled=-100000.000 
P7_P3_scaled=-100000.000 

if ($10 == 0){ 
  # check validity individually, too, some (P5) may be bad
  if ($13 > 0) {
    P5_P3_scaled=$13*P5_P3_scale  # scale P3 with P5
    P5_P3  +=P5_P3_scaled
    if (P5_P3_scaled < P5_P3m)  P5_P3m = P5_P3_scaled
    P337    +=$13
    if ($13 < P337m)  P337m = $13
    i5 += 1.
    P337a   =P337 / i5
    P5_P3a    =P5_P3 / i5
  }
  if ($14 > 0) {
    P6_P3_scaled=$14*P6_P3_scale  # scale P3 with P6
    P6_P3  +=P6_P3_scaled
    if (P6_P3_scaled < P6_P3m)  P6_P3m = P6_P3_scaled
    P761  +=$14
    if ($14 < P761m)  P761m = $14
    i6 += 1.
    P761a   =P761 / i6
    P6_P3a    =P6_P3 / i6
  }
  if ($15 > 0) {
    P7_P3_scaled=$15*P7_P3_scale  # scale P3 with P7
    P7_P3  +=P7_P3_scaled
    if (P7_P3_scaled < P7_P3m)  P7_P3m = P7_P3_scaled
    P1073   +=$15
    if ($15 < P1073m)  P1073m = $15
    i7 += 1.
    P1073a  =P1073 / i7
    P7_P3a  =P7_P3 / i7
  }
  i += 1.
  year += $1
  month += $2
  day += $3
  time += $4
  #P2#P56  +=$11
  #P3#P130  +=$12

#find minima (maxima for time)
  if ($4 > time2)   time2 = $4
  #if ($11 < P56m)  P56m = $11
  #P3#if ($12 < P130m)  P130m = $12
} #if ($10 == 0){ 

printf(fmt1, $1, $2, $3, $4, $8,$9,P6_P3_scaled,P7_P3_scaled,$13,$14,$15)

if ($7 == 0){ 
  ie += 1.
  E38  +=$8
  E175  +=$9

#find minima (maxima for time)
  if ($8 < E38m)  E38m = $8
  if ($9 < E175m)  E175m = $9
} #if ($7 == 0){ 

} # end loop, do for each record

END { # do once, at the end

#Calculate averages
# old way if (E175m != 10000000.){
if (i > 0 && ie > 0){
  yeara = year/i
  montha = month/i
  daya = day/i

  E38a    =E38 / ie   
  E175a  =E175 / ie 
  #P56a    =P56 / i 
  #P130a   =P130 / i

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
  P5_P6 = P337a/P761a
  P6_P7 = P761a/P1073a
  P5_P7 = P337a/P1073a

#VIOLATION CHECKS:

#CREATE ALERT MESSAGE CALL
  #val = sprintf("%.4e", P337f)   #P5
  #command = "/data/mta4/space_weather/aceviolation_protons.csh " val

  #if (E175m  > 100.)  system ("/data/mta4/space_weather/aceviolation_electrons.csh")

  #deleted due to P3 failure if (P130f  > 360000000.)  system (command)
# now use 50 times P5 = P337f
  P5_P6_lim=1.0  # maximum P5/P6, before data may be spurious
  if (P5_P6 < P5_P6_lim && P5_P6 > 1) {  # trust P5
    #if (P130f  > 360000000.) {
    if (P5_P3f  > 120000000.) {
      val = sprintf("%.4e", P5_P3f)   #P5
      command = "/data/mta4/space_weather/aceviolation_protonsP5.csh " val
      system (command)
    }  # if (P5_P3f  > 120000000.)  system (command)
  } else { # trust P6
    if (P6_P3f > 120000000.) {
      val = sprintf("%.4e", P6_P3f)   #P6
      command = "/data/mta4/space_weather/aceviolation_protonsP6.csh " val
      system (command)
    }  # if (P6_P3f   > 120000000.)  system (command)
    # send a message that P5 is bad
    speci = sprintf("%12.1f", P5_P6)   #P5
    speci_lim = sprintf("%8.1f", P5_P6_lim)   #P5
    command="/data/mta4/space_weather/ace_invalid_spec.csh" speci speci_lim
    #yeah, we know, turn off for now #system(command)
  } # else { # trust P6 #  if (P5_P6 < P5_P6_lim) {  # trust P5

  print " "
  print " "
  print "                        2 hour  Real-time Differential Electron and Proton Flux"
  #print "                                 Differential Flux particles/cm2-s-ster-MeV"
  print " "
  print "                   --- Electron keV ---     --------------------- Protons keV -------------------"
  #print "                   DE1         DE4        P3scaledP6      P3scaledP5         P5            FP6p           P7"
  print "                   DE1         DE4        P3scaledP6      P3scaledP7         P5            FP6p           P7"
  print "                 38-53       175-315       112-187*        112-187**       310-580       761-1220      1060-1910"

  print " "
  #printf(fmt2, "AVERAGE", E38a,E175a,P56a,P130a,P337a,P761a,P1073a)
  #printf(fmt2, "MINIMUM", E38m,E175m,P56m,P130m,P337m,P761m,P1073m)
  #printf(fmt3, "FLUENCE", E38f,E175f,P56f,P130f,P337f,P761f,P1073f)
  printf(fmt2, "AVERAGE", E38a,E175a,P6_P3a,P7_P3a,P337a,P761a,P1073a)
  if (P337m > P337a) P337m=0.  # hack, if all P5 is bad
  printf(fmt2, "MINIMUM", E38m,E175m,P6_P3m,P7_P3m,P337m,P761m,P1073m)
  printf(fmt3, "FLUENCE", E38f,E175f,P6_P3f,P7_P3f,P337f,P761f,P1073f)
  print " "
  printf(fmt4, "SPECTRA","P5/P6",P5_P6,"P5/P7",P5_P7,"P6/P7",P6_P7)
  print " "
  fmt_star="%62s %4.1f\n"
  printf(fmt_star, "* This P3 channel is currently scaled from P6 data. P3* = P6 X ", P6_P3_scale)
  #printf(fmt_star, "** This P3 channel is currently scaled from P5 data. P3** = P5 X ", P5_P3_scale)
  printf(fmt_star, "** This P3 channel is currently scaled from P7 data. P3** = P7 X ", P7_P3_scale)

}  # if (E175m != 10000000.){
else {
  print " No Valid data for last 2 hours"
  system("/data/mta4/space_weather/ace_invalid_data.csh")
} #else {
} # END
#
