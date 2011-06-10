BEGIN{ 
	time2   = -1
	Longm=10000000.
	Shortm=10000000.
	i=0.0
	ie=0.0

fmt1="%4d %2d %2d %4d %12.2e %12.2e %12.2e \n"

fmt2="%7s %14.3e %14.3e \n"
fmt3="%7s %14.3e %14.3e \n"

print "              Most recent GOES 15 observations"
print "          Solar X-ray Flux Watts per meter squared"
print " "
print " UT Date   Time     ------ X-ray Flux (nanometer) -------"
print "  YR MO DA HHMM      0.05-0.4      0.1-0.8       Ratio "
print "                      Short         Long         "
	   }

{

printf(fmt1, $1, $2, $3, $4, $7,$8,$9)

	if ($7 != -1.00e+05){ 
		i += 1.
		year += $1
		month += $2
		day += $3
		time += $4
		S1	+=$7
		L1	+=$8

#find minima (maxima for time)
		if ($4 > time2)   time2 = $4
		if ($7 < Shortm)  Shortm = $7
		if ($8 < Longm)  Longm = $8
		}

}		

END	{


	if (Shortm != 10000000.){
		yeara = year/i
		montha = month/i
		daya = day/i

		Shorta 	=S1 / i 
		Longa 	=L1 / i 

		Shortf 	=S1 *  7200.
		Longf 	=L1 * 7200. 

print " "
print " "

print "           2 hour  Real-time X-ray Flux"
print "             Watts per meter squared"
print " "

print "      ----------------------------------------------"
print "               0.05-0.4       0.1-0.4  "
print "                Short          Long    "

printf(fmt2, "AVERAGE", Shorta,Longa)
printf(fmt3, "FLUENCE", Shortf,Longf)


} 
else print " No Valid data for last 2 hours"
}
#

