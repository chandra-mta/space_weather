BEGIN{ 
	time2   = -1
	P1m=10000000.
	P2m=10000000.
	P5m=10000000.
	P8m=10000000.
	P10m=10000000.
	P11m=10000000.
	H1m=10000000.
	H2m=10000000.
	i=0.0
	ie=0.0

fmt1="%4d %2d %2d %4d %12.2f %12.5f %12.5f %12.5f %12.5f %12.5f %10.0f \n"

fmt2="%7s %14.3f %14.6f %14.6f %14.6f %14.6f %14.6f %12.0f \n"
fmt3="%7s %14.4e %14.4e %14.4e %14.4e %14.4e %14.4e %14.4e \n"

print "                                      Most recent GOES 13 observations"
print "                                    Proton Flux particles/cm2-s-ster-MeV"
print " "
print " UT Date   Time     ----------------------------- Protons MeV -------------------------------  --- HRC proxy ---"
print "  YR MO DA HHMM      0.8-4.0      4.0-9.0       40-80       350-420      500-700       >700  "
print "                        P1          P2           P5           P8           P10          P11          H2   "
	   }

{

#H1=$11*320000
H1=$10*6000+$11*270000+$12*100000
if ($11 < 0) H1=-100000
if ($11 < 0) H2=-100000
printf(fmt1, $1, $2, $3, $4, $7,$8,$11, $14,$16,$17,H1)
	if ($7 != -1.00e+05){ 
		i += 1.
		year += $1
		month += $2
		day += $3
		time += $4
		P1	+=$7
		P2	+=$8
		P5	+=$11
		P8	+=$14
		P10    +=$16
		P11	+=$17
		HP1	+=H1
		#HP2	+=H2

#find minima (maxima for time)
		if ($4 > time2)   time2 = $4
		if ($7 < P1m)  P1m = $7
		if ($8 < P2m)  P2m = $8
		if ($11 < P5m)  P5m = $11
		if ($14 < P8m)  P8m = $14
		if ($16 < P10m)  P10m = $16
		if ($17 < P11m)  P11m = $17
		if (H1 < H1m)  H1m = H1
		#if (H2 < H2m)  H2m = H2
		}

}		

END	{


	if (P1m != 10000000.){
		yeara = year/i
		montha = month/i
		daya = day/i

		P1a  	=P1 / i 
		P2a 	=P2 / i 
		P5a 	=P5 / i 
		P8a 	=P8 / i 
		P10a    =P10 / i 
		P11a    =P11 / i 
		HP1a    =HP1 / i 
		#HP2a    =HP2 / i 

		P1f  	=P1 *  7200.
		P2f 	=P2 * 7200. 
		P5f 	=P5 * 7200. 
		P8f 	=P8 * 7200. 
		P10f    =P10 * 7200. 
		P11f    =P11 * 7200. 
		HP1f    =HP1 * 7200. 
		#HP2f    =HP2 * 7200. 

#goes 10        if (P2  > 50.)  system ("/data/mta4/space_weather/goes_violation.csh" ) 

print " "
print " "

print "                                      2 hour  Real-time Proton Flux"
print "                                   Proton Flux particles/cm2-s-sr-MeV"
print " "

print "             ----------------------------------- Protons MeV -----------------------------------"
print "              0.8-4.0        4.0-9.0         40-80          350-420       500-700         >700"
print "                P1             P2             P5              P8            P10            P11             H2  "

printf(fmt2, "AVERAGE", P1a,P2a,P5a,P8a,P10a,P11a,HP1a)
printf(fmt3, "FLUENCE", P1f,P2f,P5f,P8f,P10f,P11f,HP1f)


print " "
#print "H1 = 320000*P5p "
print "H1 = 6000*P4p + 270000*P5p + 100000*P6p"
} 
else print " No Valid data for last 2 hours"
}
#

