BEGIN{ 
	time2   = -1
	E38m	=10000000.
	E175m	=10000000.
	P56m	=10000000.
	P130m	=10000000.
	P337m   =10000000.
	P761m	=10000000.
	P1073m  =10000000.

	i=0.0
	ie=0.0

fmt1="%4d %2d %2d %4d %11.3f %11.3f %11.3f %11.3f %11.3f %11.3f %11.3f\n"

fmt2="%7s %14.3f %14.3f %14.3f %14.3f %14.3f %14.3f %14.3f\n"
fmt3="%7s %14.4e %14.4e %14.4e %14.4e %14.4e %14.4e %14.4e\n"
fmt4="%7s %14s %14.3f %14s %14.3f %14s %14.3f \n"

print "                                        Most recent ACE observations"
print "                                 Differential Flux particles/cm2-s-ster-MeV"
print " "
print " UT Date   Time    --- Electron keV ---     --------------------- Protons keV -------------------"
print "  YR MO DA HHMM     38-53     175-315        47-65     112-187     310-580    761-1220   1060-1910"


	   }

 

{

#print $1" "$2" "$3" "$4" "$5" "$6" "$7"  "$8" "$9" "$10" "$11" "$12" "$13" "$14" "$15" "$16
printf(fmt1, $1, $2, $3, $4, $8,$9,$11,$12,$13,$14,$15)

	if ($10 == 0){ 
		i += 1.
		year += $1
		month += $2
		day += $3
		time += $4
		P56	+=$11
		P130	+=$12
		P337    +=$13
		P761	+=$14
		P1073   +=$15



#find minima (maxima for time)
		if ($4 > time2)   time2 = $4
		if ($11 < P56m)  P56m = $11
		if ($12 < P130m)  P130m = $12
		if ($13 < P337m)  P337m = $13
		if ($14 < P761m)  P761m = $14
		if ($15 < P1073m)  P1073m = $15
		}


	if ($7 == 0){ 
		ie += 1.
		E38	+=$8
		E175	+=$9


#find minima (maxima for time)
		if ($8 < E38m)  E38m = $8
		if ($9 < E175m)  E175m = $9

		}

}		

END	{


#Calculate averages

	if (E175m != 10000000.){
		yeara = year/i
		montha = month/i
		daya = day/i

		E38a    =E38 / ie 	
		E175a	=E175 / ie 
		P56a  	=P56 / i 
		P130a 	=P130 / i 
		P337a   =P337 / i 
		P761a 	=P761 / i 
		P1073a  =P1073 / i

#calculate 2-hour fluence
		E38f    =E38a * 7200.   #* 0.015
		E175f	=E175a * 7200.  #* 0.140
		P56f  	=P56a *  7200.  #* 0.022
		P130f 	=P130a * 7200.  #* 0.084
		P337f   =P337a * 7200.  #* 0.257
		P761f 	=P761a * 7200.  #* 0.459
		P1073f  =P1073a * 7200. #* 0.729

#calculate- minimum
		E38m    =E38m / 1. 	
		E175m	=E175m / 1. 
		P56m 	=P56m/ 1. 
		P130m 	=P130m / 1. 
		P337m   =P337m / 1. 
		P761m 	=P761m / 1. 
		P1073m  =P1073m / 1.

#Calculate Spectral indcies:
		P5_P6 = P337a/P761a
		P6_P7 = P761a/P1073a
		P5_P7 = P337a/P1073a

#VIOLATION CHECKS:

#CREATE ALERT MESSAGE CALL
        val = sprintf("%.4e", P337f)   #P5
        command = "/data/mta4/space_weather/aceviolation_protons.csh " val

#	if (E175m  > 100.)  system ("/data/mta4/space_weather/aceviolation_electrons.csh")
#test        command = "aceviolation_protons.csh " val

#deleted due to P3 failure        if (P130f  > 360000000.)  system (command)
# now use 50 times P5 = P337f

               P5_50 = 50.*P337f
	        if (P5_P6 < 10. && P5_50  > 360000000.)  system (command)

#test        if (P130f  > 36.)  system (command)
#	        if (P130m  > 100000.)  system ("ls")

print " "
print " "
print " "
print " "

print "                        2 hour  Real-time Differential Electron and Proton Flux"
#print "                                 Differential Flux particles/cm2-s-ster-MeV"
print " "
print "                   --- Electron keV ---     --------------------- Protons keV -------------------"
print "                 38-53       175-315        56-78         130-214        337-594       761-1220      1073-1802"

printf(fmt2, "AVERAGE", E38a,E175a,P56a,P130a,P337a,P761a,P1073a)
printf(fmt2, "MINIMUM", E38m,E175m,P56m,P130m,P337m,P761m,P1073m)
printf(fmt3, "FLUENCE", E38f,E175f,P56f,P130f,P337f,P761f,P1073f)
print " "
printf(fmt4, "SPECTRA","P5/P6",P5_P6,"P5/P7",P5_P7,"P6/P7",P6_P7)
} 
else print " No Valid data for last 2 hours"
}
#

