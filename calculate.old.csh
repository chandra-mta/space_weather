#! /bin/tcsh -f
#
#  THIS IS THE ACE WEB GENERATION AND ALERTS MAIL SOURCE
#  HERE WE GET THE ACE DATA,  FIND THE FIGURES FOR THE 
#  WEB PAGE AND FORMAT 
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
set WAPdir=/data/mta4/www/WL

#set today=`date '+%y%m%d'`

# 01/14/02 BDS -SEC data problems, changed to ftp2.sec.noaa.gov
#   old links marked with #sec

#sec #set file = ftp://solar.sec.noaa.gov/pub/lists/ace/ace_epam_5m.txt
set file = ftp://ftp2.sec.noaa.gov/pub/lists/ace/ace_epam_5m.txt


rm $SPACE_Wdir/returned
/opt/local/bin/lynx -source $file > $SPACE_Wdir/returned
#lynx -source http://solar.sec.noaa.gov/getftp.cgi\?get=lists/ace/ace_epam_5m.txt > $SPACE_Wdir/returned

set count = `cat $SPACE_Wdir/returned | wc -l`
#echo $count

if ($count > 28) then 
   rm $SPACE_Wdir/last45
   rm $SPACE_Wdir/lasthour
    tail -24 $SPACE_Wdir/returned > $SPACE_Wdir/lasthour
    head -24 $SPACE_Wdir/lasthour > $SPACE_Wdir/last45
    

    #run nawkscript to calculate averages and mins
    nawk -F" " -f $SPACE_Wdir/process_ace.nawk $SPACE_Wdir/last45 > $SPACE_Wdir/acedata
    nawk -F" " -f $SPACE_Wdir/proc_ace_wap1.nawk $SPACE_Wdir/last45 > $WAPdir/ace.wml
    nawk -F" " -f $SPACE_Wdir/proc_ace_wap2.nawk $SPACE_Wdir/last45 >> $WAPdir/ace.wml
#    rm /data/mta4/www/ace.html

#go collect the image 
#sec #/opt/local/bin/lynx -source http://sec.noaa.gov/ace/EPAM_3d.html | tail -3 | head -1 >! $SPACE_Wdir/tmp
/opt/local/bin/lynx -source http://ftp2.sec.noaa.gov/ace/EPAM_3d.html | tail -3 | head -1 >! $SPACE_Wdir/tmp
#remove the junk
sed s/'<IMG SRC="'/' '/1 $SPACE_Wdir/tmp | sed s/'">'/' '/1 >! $SPACE_Wdir/imagename

#cat imagename | xargs -i set image3d = {}
#create the line for the link
set image_var=`cat $SPACE_Wdir/imagename`


#go and collect Kp image 
#sec #/opt/local/bin/lynx -source http://solar.sec.noaa.gov/rt_plots/kp_3d.cgi | tail -15 | head -1 >! $SPACE_Wdir/tmpkp
# from costello
#sec #/opt/local/bin/lynx -source http://www.sec.noaa.gov/rpc/costello/pkp_15m_7d.html | tail -9 | head -1 > ! $SPACE_Wdir/tmpkp
/opt/local/bin/lynx -source http://ftp2.sec.noaa.gov/rpc/costello/pkp_15m_7d.html | tail -9 | head -1 > ! $SPACE_Wdir/tmpkp
sed s/'<CENTER><IMG SRC="'/''/1 $SPACE_Wdir/tmpkp | sed s/'"><'/' '/1 | sed s/'\/CENTER>'/''/1 >! $SPACE_Wdir/kpimagename

set image_varkp=`cat $SPACE_Wdir/kpimagename`


#THIS FILE EXISTS AND IS STATIC, NO NEED TO RECREATE IN-LINE.
#echo '<HR> <li><a href ="alerts/ace.archive"> 3-day archive </a>of the latest ACE data.' >! $SPACE_Wdir/rob1
#echo '<li><a href="alerts/fluance.dat"> Latest orbital fluance when CHANDRA is above 70kkm. </a>'  >>  $SPACE_Wdir/rob1
#echo '<li><a href="alerts/ace_fluence.arc"> History of fluance when CHANDRA has been above 70kkm. </a>'  >>  $SPACE_Wdir/rob1
#echo '<li><a href="alerts/about_ace_page.html"> About our ACE Monitoring and Alerts.</a>'  >>  $SPACE_Wdir/rob1


#sec #echo '<HR><CENTER><IMG SRC="http://sec.noaa.gov/ace/'$image_var'"></CENTER>' >! $SPACE_Wdir/image
echo '<HR><CENTER><IMG SRC="http://ftp2.sec.noaa.gov/ace/'$image_var'"></CENTER>' >! $SPACE_Wdir/image
#sec #echo '<HR><CENTER><IMG SRC="http://www.sec.noaa.gov/rpc/costello/'$image_varkp'"></CENTER>' >! $SPACE_Wdir/kpimage
echo '<HR><CENTER><IMG SRC="http://ftp2.sec.noaa.gov/rpc/costello/'$image_varkp'"></CENTER>' >! $SPACE_Wdir/kpimage
cat $SPACE_Wdir/header $SPACE_Wdir/acedata  $SPACE_Wdir/image $SPACE_Wdir/kpimage $SPACE_Wdir/rob1 $SPACE_Wdir/footer >! $WEBdir/ace.html


endif


