#! /bin/tcsh -f
# 07 nov 03 bds
#   this is a test of the new ACE data
#   just show the file, no scaling
#   for comparison to old values
#   no alerts (calls nawk_no_alerts)
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
set WEBdir=/data/mta4/www/XACE2
set WAPdir=/data/mta4/www/WL

#set today=`date '+%y%m%d'`

# 01/14/02 BDS -SEC data problems, changed to www.sec.noaa.gov
#   old links marked with #sec
# 11/06/03 BDS - change www.sec.noaa.gov to www.sec.noaa.gov (web farm)

#sec set file = ftp://solar.sec.noaa.gov/pub/lists/ace/ace_epam_5m.txt
set file = ftp://ftp2.sec.noaa.gov/pub/lists/ace/ace_epam_5m.txt

#rm $SPACE_Wdir/returned
#/opt/local/bin/lynx -source $file > $SPACE_Wdir/returned
#lynx -source http://solar.sec.noaa.gov/getftp.cgi\?get=lists/ace/ace_epam_5m.txt > $SPACE_Wdir/returned

set count = `cat $SPACE_Wdir/returned | wc -l`
#echo $count

if ($count > 28) then 
   #rm $SPACE_Wdir/last45
   #rm $SPACE_Wdir/lasthour
    #tail -24 $SPACE_Wdir/returned > $SPACE_Wdir/lasthour
    #head -24 $SPACE_Wdir/lasthour > $SPACE_Wdir/last45
    

    #run nawkscript to calculate averages and mins
    #nawk -F" " -f $SPACE_Wdir/process_ace_no_alerts.nawk $SPACE_Wdir/last45 > $SPACE_Wdir/xacedata2
    $SPACE_Wdir/process_ace3.0.pl > $SPACE_Wdir/xacedata2
#    rm /data/mta4/www/ace.html

#go collect ACE image and invert. 
#/opt/local/bin/lynx -source http://www.sec.noaa.gov/ace/Epam_7d.gif | /opt/local/bin/convert -negate - - >! $WEBdir/Epam_7di.gif

#go and collect Kp image 
#/opt/local/bin/lynx -source http://www.sec.noaa.gov/rpc/costello/pkp_15m_7d.html | tail -9 | head -1 > ! $SPACE_Wdir/tmpkp
sed s/'<CENTER><IMG SRC="'/''/1 $SPACE_Wdir/tmpkp | sed s/'"><'/' '/1 | sed s/'\/CENTER>'/''/1 >! $SPACE_Wdir/kpimagename
set image_varkp=`cat $SPACE_Wdir/kpimagename`
#
#/opt/local/bin/lynx -source http://www.sec.noaa.gov/rpc/costello/$image_varkp >!  $WEBdir/costello.gif
#/opt/local/bin/convert -negate  $WEBdir/costello.gif - >! $WEBdir/costello_i.gif



#THIS FILE EXISTS AND IS STATIC, NO NEED TO RECREATE IN-LINE.
#echo '<HR> <li><a href ="alerts/ace.archive"> 3-day archive </a>of the latest ACE data.' >! $SPACE_Wdir/rob1
#echo '<li><a href="alerts/fluance.dat"> Latest orbital fluance when CHANDRA is above 70kkm. </a>'  >>  $SPACE_Wdir/rob1
#echo '<li><a href="alerts/ace_fluence.arc"> History of fluance when CHANDRA has been above 70kkm. </a>'  >>  $SPACE_Wdir/rob1
#echo '<li><a href="alerts/about_ace_page.html"> About our ACE Monitoring and Alerts.</a>'  >>  $SPACE_Wdir/rob1

#sec #echo '<HR><CENTER><IMG SRC="http://sec.noaa.gov/ace/'$image_var'"></CENTER>' >! $SPACE_Wdir/image
#echo '<HR><CENTER><IMG SRC="http://www.sec.noaa.gov/ace/Epam_7d.gif'"></CENTER>' >! $SPACE_Wdir/image2
#/opt/local/bin/lynx -source http://www.sec.noaa.gov/rpc/costello/$image_varkp | /opt/local/bin/convert -negate - - >! test.gif
##sec #echo '<HR><CENTER><IMG SRC="http://www.sec.noaa.gov/rpc/costello/'$image_varkp'"></CENTER>' >! $SPACE_Wdir/kpimage
#echo '<HR><CENTER><IMG SRC="http://www.sec.noaa.gov/rpc/costello/'$image_varkp'"></CENTER>' >! $SPACE_Wdir/kpimage


cat $SPACE_Wdir/header $SPACE_Wdir/xacedata2  $SPACE_Wdir/image2 $SPACE_Wdir/rob1 $SPACE_Wdir/footer >! $WEBdir/ace2.html


cat $SPACE_Wdir/header_i $SPACE_Wdir/acedata  $SPACE_Wdir/image_i  $SPACE_Wdir/rob1 $SPACE_Wdir/footer >! $WEBdir/ace2_i.html


endif


