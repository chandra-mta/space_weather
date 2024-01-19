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

fmt1="%4d %2d %2d %4d <br/> %11.3f <br/>\n"

fmt2="%7s <br/> %14.3f <br/>\n"

print "<br/> "
print "UT Date Time<br/>"
print "112-187keV<br/>"
	   }

{
P3=$12
if (P3 < 0) P3=-100000

printf(fmt1, $1, $2, $3, $4, P3)

}		

END	{


print "<br/> "
print "<a href='sot.wml'>SOT Home</a><br/>"
print "</p>"
print "</card>"
print "</wml>"
}

#

