#! /bin/tcsh -f


set SPACE_Wdir=/data/mta4/space_weather
set WEBdir=/data/mta4/www

#set today=`date '+%y%m%d'`

# This script now generates output to G15_xray.html
# October 28, 2010 -- GOES 15 became the Primary SWPC GOES X-ray and SXI satellite replacing GOES 14. 
#GOES 14 will be put into storage mode. 
#There are only minor differences in the appearance of the GOES 14 and GOES 15 X-ray data at the lowest flux levels.

#There is no SWPC Secondary GOES X-ray or SXI satellite. 

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
set file = http://www.swpc.noaa.gov/ftpdir/lists/xray/Gp_xr_5m.txt

#/opt/local/bin/lynx -source $file
/opt/local/bin/lynx -source $file >! $SPACE_Wdir/G14returned1

    tail -24 $SPACE_Wdir/G14returned1 | head -24 >! $SPACE_Wdir/G14returned

    #run nawkscript to calculate averages and mins
    nawk -F" " -f $SPACE_Wdir/G14_process.nawk $SPACE_Wdir/G14returned >! $SPACE_Wdir/G14data

#go collect the image 
#sec #/opt/local/bin/lynx -source http://solar.sec.noaa.gov/rt_plots/satenvBL.html | tail -10 | head -1 >! $SPACE_Wdir/G10tmp
#lynx_fname/opt/local/bin/lynx -source http://www.sec.noaa.gov/rt_plots/satenvBL.html | tail -14 | head -1 >! $SPACE_Wdir/G10tmp
#remove the junk
#lynx_fnamesed s/'<center><img src="'/''/1 $SPACE_Wdir/G10tmp  | sed s/'"><'/' '/1 | sed s/'\/center>'/' '/1 >! $SPACE_Wdir/G10imagename

# no need to do all this anymore,
#  G12 gets the images and
#  G12image and G12image2are now static, so just plug in
#create the line for the link
#set image_var=`cat $SPACE_Wdir/G12imagename`

#####################################################################

#go collect the second image image 
#sec #/opt/local/bin/lynx -source http://solar.sec.noaa.gov/rt_plots/pro_3d.html | tail -11 | head -1 >! $SPACE_Wdir/G10tmp2
#lynx_fname/opt/local/bin/lynx -source http://www.sec.noaa.gov/rt_plots/pro_3d.html | tail -11 | head -1 >! $SPACE_Wdir/G10tmp2
#remove the junk
#lynx_fnamesed s/'<center><img src="'/''/1 $SPACE_Wdir/G10tmp2  | sed s/'"><'/' '/1 | sed s/'\/center>'/' '/1 >! $SPACE_Wdir/G10imagename2

#create the line for the link
#set image_var2=`cat $SPACE_Wdir/G12imagename2`

#####################################################################


#sec #echo '<HR><CENTER><IMG SRC="http://solar.sec.noaa.gov'$image_var'"></CENTER>' >! $SPACE_Wdir/G10image
#echo '<HR><CENTER><IMG SRC="http://www.sec.noaa.gov'$image_var'"></CENTER>' >! $SPACE_Wdir/G10image
#sec #echo '<HR><CENTER><IMG SRC="http://solar.sec.noaa.gov'$image_var2'"></CENTER>' >! $SPACE_Wdir/G10image2
#echo '<HR><CENTER><IMG SRC="http://www.sec.noaa.gov'$image_var2'"></CENTER>' >! $SPACE_Wdir/G10image2

#####################################################################
# place Rob's image into the mix:
#echo '<hr><ul><li> P1 = Protons from 0.8 -   4 MeV units #/cm2-s-sr-MeV (Blue) <li> P2 = Protons from   4 -   9 MeV units #/cm2-s-sr-MeV (Green) <li> P5 = Protons from  40 -  80 MeV units #/cm2-s-sr-MeV (Cyan)</ul>' >> $SPACE_Wdir/G10image2

#echo '<br> The P2 and P5 channels can be approximately scaled to the EPHIN P4GM and P41GM rates. <br>We plot the scaled RADMON limits for P4GM and P41GM on the plot.' >> $SPACE_Wdir/G10image2

#echo '<CENTER><IMG SRC="./RADIATION/pgplot.gif"></CENTER>' >> $SPACE_Wdir/G10image2

#sec #echo '<ul><li> <a href="ftp://ftp.sec.noaa.gov/pub/lists/pchan/G8pchan_5m.txt">GOES-8 five minute average data.</a><li> <a href="ftp://ftp.sec.noaa.gov/pub/lists/pchan/G10pchan_5m.txt">GOES-10 five minute average data.</a>' >> $SPACE_Wdir/G10image2
#echo '<ul><li> <a href="ftp://www.sec.noaa.gov/pub/lists/pchan/G8pchan_5m.txt">GOES-8 five minute average data.</a><li> <a href="ftp://www.sec.noaa.gov/pub/lists/pchan/G10pchan_5m.txt">GOES-10 five minute average data.</a><li> <a href="ftp://www.sec.noaa.gov/pub/lists/pchan/G11pchan_5m.txt">GOES-11 five minute average data.</a><li> <a href="ftp://www.sec.noaa.gov/pub/lists/pchan/G12pchan_5m.txt">GOES-12 five minute average data.</a>' >> $SPACE_Wdir/G10image2


cat $SPACE_Wdir/G14header $SPACE_Wdir/G14data  $SPACE_Wdir/G14image $SPACE_Wdir/G15image2  $SPACE_Wdir/G15footer >! $WEBdir/G15_xray.html


endif


