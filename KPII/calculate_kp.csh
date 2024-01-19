#! /bin/tcsh -f
#
#  THIS IS THE KP WEB GENERATION AND ALERTS MAIL SOURCE
#  HERE WE GET THE KP DATA,  FIND THE FIGURES FOR THE 
#  WEB PAGE AND FORMAT 
#
#  CALLS:  process_kp.nawk WHICH CALCULATES MINS AND MAXS OVER TIME RANGE
#          change line 105 to change limit
#          CALLS: aceviolation_PREDI_Y.csh which pages people when COSTELLO violates yellow limits 
#          CALLS: aceviolation_PREDI_R.csh which pages people when COSTELLO violates red limits 
#          CALLS: aceviolation_ESTKP.csh which pages people when EST Kp violates limits 
#               ----- these are obsolete!!
#
#   inpupt file chnanged to ftp://ftp.swpc.noaa.gov/pub/lists/wingkp/wingkp_list.txt   Oct 21, 2015 (TI)
#   plot link changed to: http://legacy-www.swpc.noaa.gov/wingkp/wingkp_15m_7d.gif
#
#   last update: Nov 16, 2015  
#               /opt/local/bin/lynx ----> /usr/bin/lynx
#               nawk ---> gawk
#

set SPACE_Wdir=/data/mta4/space_weather/KPII
set WEBdir=/data/mta4/www


set file = ftp://ftp.swpc.noaa.gov/pub/lists/wingkp/wingkp_list.txt 

lynx -source $file | tail -12 >! $SPACE_Wdir/Kp_INDEX.txt

#
#--- run nawkscript to calculate averages and mins
#
    gawk -F" " -f $SPACE_Wdir/process_kp.nawk $SPACE_Wdir/Kp_INDEX.txt >! $SPACE_Wdir/kpdata

    tail -1 $SPACE_Wdir/kpdata >!  $SPACE_Wdir/current_Kp.txt

set image_varkp=`cat $SPACE_Wdir/kpimagename`


echo '<HR><CENTER><IMG SRC="http://legacy-www.swpc.noaa.gov/wingkp/wingkp_15m_7d.gif"></CENTER>' >! $SPACE_Wdir/kpimage
cat $SPACE_Wdir/kpheader $SPACE_Wdir/kpdata  $SPACE_Wdir/kpimage $SPACE_Wdir/rob1 $SPACE_Wdir/footer >! $WEBdir/kp.html





