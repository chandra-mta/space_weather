BEGIN{ 
	time2   = -1
	PREDI	=0.
	LIT	=1000.
	ESTKP	=0.
	P130m	=10000000.
	P337m   =10000000.
	P761m	=10000000.
	P1073m  =10000000.

	i=0.0
	ie=0.0

fmt1="%4d %2d %2d %4d %4d %2d %2d %6d %11.3f %11.3f %11.3f\n"

fmt2="%20s %14.2f  \n"

print "                            15-minute Costello Geomagnetic Activity Index"
print " "
print " "
print " UT Date   Time         -Predicted Time-  Predicted  Lead-time  USAF Est."
print "  YR MO DA  HHMM   S     YR MO DA  HHMMSS    Index    in Minutes     Kp "
print "-------------------------------------------------------------------------"


	   }

 

{

#print $1" "$2" "$3" "$4" "$5" "$6" "$7"  "$8" "$9" "$10" "$11" "$12" "$13" "$14" "$15" "$16
printf(fmt1, $1, $2, $3, $4, $6,$7,$8,$9,$10,$11,$12)

	if ($5 == 0){ 
		i += 1.
		year += $1
		month += $2
		day += $3
		time += $4


#find minima (maxima for time)
		if ($4 > time2)   time2 = $4
		if ($10 > PREDI)    PREDI = $10
		if ($11 < LIT)  LIT = $11
		if ($12 > ESTKP)  ESTKP = $12
		}


#	if ($7 == 0){ 
#		ie += 1.
#		E38	+=$8
#		E175	+=$9##
##

#find minima (maxima for time)
#		if ($8 < E38m)  E38m = $8
#		if ($9 < E175m)  E175m = $9
#
#		}

} 		


END	{



#	if (E175m  > 100.)  system ("/data/mta4/space_weather/aceviolation_electrons.csh")
         if (PREDI  > 5.5)  system("/data/mta4/space_weather/aceviolation_PREDI_Y.csh "PREDI"  " LIT)
         if (PREDI  > 6.5)  system("/data/mta4/space_weather/aceviolation_PREDI_R.csh "PREDI"  " LIT)
         if (ESTKP  > 5.9)  system("/data/mta4/space_weather/aceviolation_ESTKP.csh " ESTKP)
#	        if (P130m  > 100000.)  system ("ls")

print " "
print " "
print " "
print " "


#printf(fmt2, "AVERAGE", E38a,E175a,P56a,P130a,P337a,P761a,P1073a)
printf(fmt2, "COSTELLO MAXIMUM:", PREDI)
printf(fmt2, "USAF MAXIMUM:", ESTKP)
printf(fmt2, "MINIMUM LEAD TIME:", PREDI,LIT,ESTKP)
#printf(fmt2, "FLUENCE", E38f,E175f,P56f,P130f,P337f,P761f,P1073f)
#
} 

#

