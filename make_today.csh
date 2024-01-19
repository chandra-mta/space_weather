#!/bin/csh -f

rm /data/mta2/swolk/HH30/yesterday

set today=`date '+%y%m%d'`
set md=`date '+%m/%d'`
echo $today $md > /data/mta2/swolk/HH30/yesterday 

#echo "make yesterday ran" |mail swolk
