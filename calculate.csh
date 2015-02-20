#! /usr/bin/env /bin/csh

# test2
#
#  THIS IS THE ACE WEB GENERATION AND ALERTS MAIL SOURCE
#  HERE WE GET THE ACE DATA,  FIND THE FIGURES FOR THE 
#  WEB PAGE AND FORMAT. 
# 
#  ADDED code to create reversed page 13 Aug 2002 - SJW
#  CHANGES: image (2/_i) changed KP from costello to SEC  20 Aug 2002 - SJW
#           changed back the next day.
#
#  CALLS:  process_ace.nawk WHICH CALCULATES MINS AND MAXS OVER TIME RANGE
#          change line 105 to change limit
#          CALLS: aceviolation_protons.csh which pages people  
#
# TO RESET THE ALERTS SYSTEM, REMOVE THE "prot_violate" files
# from /home/swolk , e.g.
#
#scrapper>cd /home/swolk
#scrapper>mv prot_violate_PREDI prot_violate_PREDI.08Jun2000
#scrapper>mv prot_violate_ESTKP  prot_violate_ESTKP.08Jun2000
#scrapper>mv prot_violate prot_violate.08Jun2000

set SPACE_Wdir=/data/mta4/space_weather
set WEBdir=/data/mta4/www

#set today=`date '+%y%m%d'`

# 01/14/02 BDS -SEC data problems, changed to www.sec.noaa.gov
#   old links marked with #sec
# 11/06/03 BDS - change www.sec.noaa.gov to www.sec.noaa.gov (web farm)
# 11/14/03 BDS - make our own plot, with scaled P3 values
#                old sec plot instructions are commented out
#                with #sec_plot

#sec set file = ftp://solar.sec.noaa.gov/pub/lists/ace/ace_epam_5m.txt
#set file = ftp://www.sec.noaa.gov/pub/lists/ace/ace_epam_5m.txt
set file = ftp://ftp.sec.noaa.gov/pub/lists/ace/ace_epam_5m.txt
#set file = http://sec.noaa.gov/ftpdir/lists/ace/ace_epam_5m.txt
#set file = http://legacy-www.swpc.noaa.gov/ftpdir/lists/ace/ace_epam_5m.txt

/bin/rm $SPACE_Wdir/returned
lynx -source $file > $SPACE_Wdir/returned

set count = `cat $SPACE_Wdir/returned | wc -l`

if ($count > 28) then 
   /bin/rm $SPACE_Wdir/last45
   /bin/rm $SPACE_Wdir/lasthour
    tail -24 $SPACE_Wdir/returned > $SPACE_Wdir/lasthour
    head -24 $SPACE_Wdir/lasthour > $SPACE_Wdir/last45
    

    #run nawkscript to calculate averages and mins
    gawk -F" " -f $SPACE_Wdir/process_ace.nawk $SPACE_Wdir/last45 > $SPACE_Wdir/acedata
    #smart_proc#
    # if P3 might be good turn on "smarter" processing, 
    #  -comment out 1 line above ( nawf -F ...)
    #  -uncomment line below (process_ace3.0.pl)
    #  -leave wap processing, it's all we've got
    #smart_proc#$SPACE_Wdir/process_ace3.0.pl > $SPACE_Wdir/acedata

#go collect ACE image and invert. 
lynx -source http://services.swpc.noaa.gov/images/ace-epam-7-day.gif | /usr/bin/convert -negate - - >! $WEBdir/Epam_7di.gif
lynx -source http://services.swpc.noaa.gov/images/ace-epam-7-day.gif >! $WEBdir/Epam_7d.gif
lynx -source http://services.swpc.noaa.gov/images/ace-epam-7-day.gif >! $WEBdir/mta_ace_plot.gif
/usr/bin/convert -negate $WEBdir/mta_ace_plot_P3.gif $WEBdir/Epam_7di_P3.gif

# get wind speed etc. plot
lynx -source http://services.swpc.noaa.gov/images/ace-mag-swepam-7-day.gif >! $WEBdir/Mag_swe_7d.gif
/usr/bin/convert -negate $WEBdir/Mag_swe_7d.gif $WEBdir/Mag_swe_7di.gif

#go and collect Kp image 
#/opt/local/bin/lynx -source http://www.sec.noaa.gov/rpc/costello/pkp_15m_7d.html | tail -9 | head -1 > ! $SPACE_Wdir/tmpkp
#sed s/'<CENTER><IMG SRC="'/''/1 $SPACE_Wdir/tmpkp | sed s/'"><'/' '/1 | sed s/'\/CENTER>'/''/1 >! $SPACE_Wdir/kpimagename
#set image_varkp=`cat $SPACE_Wdir/kpimagename`

lynx -source http://services.swpc.noaa.gov/images/wing-kp-24-hour.gif >!  $WEBdir/wingkp.gif
/usr/bin/convert -negate  $WEBdir/wingkp.gif - >! $WEBdir/wingkp_i.gif

cat $SPACE_Wdir/header $SPACE_Wdir/acedata  $SPACE_Wdir/image2 $SPACE_Wdir/rob1 $SPACE_Wdir/footer >! $WEBdir/ace.html

cat $SPACE_Wdir/header_i $SPACE_Wdir/acedata  $SPACE_Wdir/image_i  $SPACE_Wdir/rob1 $SPACE_Wdir/footer >! $WEBdir/ace_i.html

endif


