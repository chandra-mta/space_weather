BEGIN{ 
	time2   = -1
	P1m=10000000.
	P2m=10000000.
	P5m=10000000.
	P8m=10000000.
	P10m=10000000.
	P11m=10000000.
	i=0.0
	ie=0.0

fmt1="%4d %2d %2d %4d %12.2f %12.3f %12.3f %12.4f %12.4f %12.4f %12.1f %8.1f %12.1f\n"

fmt2="%7s %14.2f %14.3f %14.3f %14.4f %14.4f %14.4f %14.1f %14.1f %14.1f \n"
fmt3="%7s %14.4e %14.4e %14.4e %14.4e %14.4e %14.4e %14.4e %14.4e %14.4e \n"

print "                                                     Most recent GOES 13 observations"
print "                                              Solar Particle and Electron Flux particles/cm2-s-ster"
print " "
print " UT Date   Time       ----------------------------------------------------------------------------------------------------------"
print "  YR MO DA HHMM        P >1        P >5       P >10       P >30        P >50        P >100        E >0.8       E >2.0     E >4.0"
print "            "
	   }

{

printf(fmt1, $1, $2, $3, $4, $7,$8,$9,$10,$11,$12,$13,$14,$15)

	if ($7 != -1.00e+05){ 
		i += 1.
		year += $1
		month += $2
		day += $3
		time += $4
		P1	+=$7
		P5	+=$8
		P10	+=$9 
		P30	+=$10
		P50    +=$11
		P100	+=$12
		E08 	+=$13
		E2 	+=$14
		E4 	+=$15

#find minima (maxima for time)
		if ($4 > time2)   time2 = $4
		if ($7 < P1m)  P1m = $7
		if ($8 < P5m)  P5m = $8
		if ($9  < P10m)  P10m = $9 
		if ($10 < P30m)  P30m = $10
		if ($11 < P50m)  P50m = $11
		if ($12 < P100m)  P100m = $12
		if ($13 < E08m)  E08m = $13
		if ($14 < E2m)  E2m = $14
		if ($15 < E4m)  E4m = $15
		}

}		

END	{


	if (P1m != 10000000.){
		yeara = year/i
		montha = month/i
		daya = day/i

		P1a  	=P1 / i 
		P5a 	=P5 / i 
		P10a 	=P10 / i 
		P30a 	=P30 / i 
		P50a    =P50 / i 
		P100a    =P100 / i 
		E08a    =E08 / i 
		E2a    =E2  / i 
		E4a    =E4  / i 

		P1f  	=P1 *  7200.
		P5f 	=P5 * 7200. 
		P10f 	=P10 * 7200. 
		P30f 	=P30 * 7200. 
		P50f    =P50 * 7200. 
		P100f    =P100 * 7200. 
		E08f    =E08 * 7200. 
		E2f    =E2 * 7200. 
		E4f    =E4 * 7200. 

#goes 10        if (P2  > 50.)  system ("/data/mta4/space_weather/goes_violation.csh" ) 

print " "
print " "

print "                                              Solar Particle and Electron Flux particles/cm2-s-ster"
print " "
print "                  ----------------------------------------------------------------------------------------------------------------------------"
print "                  P >1        P >5        P >10          P >30           P >50         P >100           E >0.8         E >2.0         E >4.0"
print "            "

printf(fmt2, "AVERAGE", P1a,P5a,P10a,P30a,P50a,P100a,E08a,E2a,E4a)
printf(fmt3, "FLUENCE", P1f,P5f,P10f,P30f,P50f,P100f,E08f,E2f,E4f)


} 
else print " No Valid data for last 2 hours"
}
#

