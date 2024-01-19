#! /bin/tcsh -f


set SPACE_Wdir=/data/mta4/space_weather
set WEBdir=/data/mta4/www

#set today=`date '+%y%m%d'`

# 01/14/02 BDS -SEC data problems, changed to www.sec.noaa.gov
#   old links marked with #sec
# 11/12/03 BDS -change to non-integrated display, like G-12
#              -change image links from www.sec to www.sec
#               data lynx calls should stay ftp2, www doesn't work
#              -turn off lynx calls to collect file names, get file
#               name from goes 12 run.  To turn back on delete #lynx_fname
#               and change G12image to G10image
# 04/23/04 BDS - some data probs, change all www.sec back to www.sec
# 12/01/09 BDS - update for G14; G10 decommissioned

#sec #set file = gopher://solar.sec.noaa.gov:70/00/lists/particle/G10part_5m
#set file = gopher://www.sec.noaa.gov:70/00/lists/particle/G10part_5m
#set file = gopher://www.sec.noaa.gov:70/00/lists/pchan/G10pchan_5m.txt
#set file = http://www.sec.noaa.gov/ftpdir/lists/pchan/G10pchan_5m.txt
#set file = ftp://ftp.sec.noaa.gov/pub/lists/pchan/G10pchan_5m.txt
#set file = http://www.sec.noaa.gov/ftpdir/lists/pchan/G14pchan_5m.txt
#set file = http://www.sec.noaa.gov/ftpdir/lists/xray/Gp_xr_5m.txt
#    set file = http://legacy-www.swpc.noaa.gov/ftpdir/lists/xray/Gp_xr_5m.txt
# updated Oct 6, 2015 by SJW 
    set file =    http://services.swpc.noaa.gov/text/goes-xray-flux-primary.txt

#/opt/local/bin/lynx -source $file
#/usr/bin/lynx -source $file >! $SPACE_Wdir/G14returned1
wget -q -O $SPACE_Wdir/G14returned1 $file

    tail -24 $SPACE_Wdir/G14returned1 | head -24 >! $SPACE_Wdir/G14returned

    #run nawkscript to calculate averages and mins
    awk -F" " -f $SPACE_Wdir/G14_process.nawk $SPACE_Wdir/G14returned >! $SPACE_Wdir/G14data

cat $SPACE_Wdir/G14header $SPACE_Wdir/G14data  $SPACE_Wdir/G14image $SPACE_Wdir/G12image2  $SPACE_Wdir/G14footer >! $WEBdir/G15_xray.html


endif


