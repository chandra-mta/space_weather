#! /bin/tcsh -f


set SPACE_Wdir=/data/mta4/space_weather
set WEBdir=/data/mta4/www

#set today=`date '+%y%m%d'`

# 01/14/02 BDS -SEC data problems, changed to ftp2.sec.noaa.gov
#   old links marked with #sec

#sec #set file = gopher://solar.sec.noaa.gov:70/00/lists/particle/G10part_5m
set file = gopher://ftp2.sec.noaa.gov:70/00/lists/particle/G10part_5m


/opt/local/bin/lynx -source $file >! $SPACE_Wdir/G10returned1
#debug /opt/local/bin/lynx -source $file



    tail -25 $SPACE_Wdir/G10returned1 | head -24 >! $SPACE_Wdir/G10returned


    #run nawkscript to calculate averages and mins
    nawk -F" " -f $SPACE_Wdir/G10_process.nawk $SPACE_Wdir/G10returned >! $SPACE_Wdir/G10data

#go collect the image 
#sec #/opt/local/bin/lynx -source http://solar.sec.noaa.gov/rt_plots/satenvBL.html | tail -10 | head -1 >! $SPACE_Wdir/G10tmp
/opt/local/bin/lynx -source http://ftp2.sec.noaa.gov/rt_plots/satenvBL.html | tail -14 | head -1 >! $SPACE_Wdir/G10tmp
#remove the junk
sed s/'<center><img src="'/''/1 $SPACE_Wdir/G10tmp  | sed s/'"><'/' '/1 | sed s/'\/center>'/' '/1 >! $SPACE_Wdir/G10imagename

#create the line for the link
set image_var=`cat $SPACE_Wdir/G10imagename`

#####################################################################

#go collect the second image image 
#sec #/opt/local/bin/lynx -source http://solar.sec.noaa.gov/rt_plots/pro_3d.html | tail -11 | head -1 >! $SPACE_Wdir/G10tmp2
/opt/local/bin/lynx -source http://ftp2.sec.noaa.gov/rt_plots/pro_3d.html | tail -11 | head -1 >! $SPACE_Wdir/G10tmp2
#remove the junk
sed s/'<center><img src="'/''/1 $SPACE_Wdir/G10tmp2  | sed s/'"><'/' '/1 | sed s/'\/center>'/' '/1 >! $SPACE_Wdir/G10imagename2

#create the line for the link
set image_var2=`cat $SPACE_Wdir/G10imagename2`

#####################################################################


#sec #echo '<HR><CENTER><IMG SRC="http://solar.sec.noaa.gov'$image_var'"></CENTER>' >! $SPACE_Wdir/G10image
echo '<HR><CENTER><IMG SRC="http://ftp2.sec.noaa.gov'$image_var'"></CENTER>' >! $SPACE_Wdir/G10image
#sec #echo '<HR><CENTER><IMG SRC="http://solar.sec.noaa.gov'$image_var2'"></CENTER>' >! $SPACE_Wdir/G10image2
echo '<HR><CENTER><IMG SRC="http://ftp2.sec.noaa.gov'$image_var2'"></CENTER>' >! $SPACE_Wdir/G10image2

#####################################################################
# place Rob's image into the mix:
echo '<hr><ul><li> P1 = Protons from 0.8 -   4 MeV units #/cm2-s-sr-MeV (Blue) <li> P2 = Protons from   4 -   9 MeV units #/cm2-s-sr-MeV (Green) <li> P5 = Protons from  40 -  80 MeV units #/cm2-s-sr-MeV (Cyan)</ul>' >> $SPACE_Wdir/G10image2

echo '<br> The P2 and P5 channels can be approximately scaled to the EPHIN P4GM and P41GM rates. <br>We plot the scaled RADMON limits for P4GM and P41GM on the plot.' >> $SPACE_Wdir/G10image2

echo '<CENTER><IMG SRC="./RADIATION/pgplot.gif"></CENTER>' >> $SPACE_Wdir/G10image2

#sec #echo '<ul><li> <a href="ftp://ftp.sec.noaa.gov/pub/lists/pchan/G8pchan_5m.txt">GOES-8 five minute average data.</a><li> <a href="ftp://ftp.sec.noaa.gov/pub/lists/pchan/G10pchan_5m.txt">GOES-10 five minute average data.</a>' >> $SPACE_Wdir/G10image2
echo '<ul><li> <a href="ftp://ftp2.sec.noaa.gov/pub/lists/pchan/G8pchan_5m.txt">GOES-8 five minute average data.</a><li> <a href="ftp://ftp2.sec.noaa.gov/pub/lists/pchan/G10pchan_5m.txt">GOES-10 five minute average data.</a><li> <a href="ftp://ftp2.sec.noaa.gov/pub/lists/pchan/G11pchan_5m.txt">GOES-11 five minute average data.</a><li> <a href="ftp://ftp2.sec.noaa.gov/pub/lists/pchan/G12pchan_5m.txt">GOES-12 five minute average data.</a>' >> $SPACE_Wdir/G10image2


cat $SPACE_Wdir/G10header $SPACE_Wdir/G10data  $SPACE_Wdir/G10image $SPACE_Wdir/G10image2  $SPACE_Wdir/G10footer >! $WEBdir/G10.html


endif


