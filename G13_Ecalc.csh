#! /bin/tcsh -f


set SPACE_Wdir=/data/mta4/space_weather
set WEBdir=/data/mta4/www

#set today=`date '+%y%m%d'`

# 01/14/02 BDS -SEC data problems, changed to www.sec.noaa.gov
#   old links marked with #sec


#sec #set file = gopher://solar.sec.noaa.gov:70/00/lists/particle/G12part_5m
# due to P6 and P7 channel failure on GOES12, particle measures are
#  not available, we'll do these a little differently from G8 and G10.
#set file = gopher://www.sec.noaa.gov:70/00/lists/particle/G12part_5m
#set file = gopher://www.sec.noaa.gov:70/00/lists/pchan/G12pchan_5m.txt
#set file = http://www.sec.noaa.gov/ftpdir/lists/pchan/G12pchan_5m.txt
#set file = ftp://ftp.sec.noaa.gov/pub/lists/pchan/G12pchan_5m.txt
#set file = http://www.sec.noaa.gov/ftpdir/lists/pchan/G12pchan_5m.txt
set file = http://www.swpc.noaa.gov/ftpdir/lists/particle/Gp_part_5m.txt

/opt/local/bin/lynx -source $file >! $SPACE_Wdir/G13Ereturned1
#debug /opt/local/bin/lynx -source $file



    tail -24 $SPACE_Wdir/G13Ereturned1 | head -24 >! $SPACE_Wdir/G13Ereturned


    #run nawkscript to calculate averages and mins
    nawk -F" " -f $SPACE_Wdir/G13_Eprocess.nawk $SPACE_Wdir/G13Ereturned >! $SPACE_Wdir/G13Edata

/opt/local/bin/lynx -source http://www.swpc.noaa.gov/rt_plots/Electron.gif >! $WEBdir/elec_3d.gif

#####################################################################

#####################################################################
# place Rob's image into the mix:
#echo '<hr><ul><li> P1 = Protons from 0.8 -   4 MeV units #/cm2-s-sr-MeV (Blue) <li> P2 = Protons from   4 -   9 MeV units #/cm2-s-sr-MeV (Green) <li> P5 = Protons from  40 -  80 MeV units #/cm2-s-sr-MeV (Cyan)</ul>' >> $SPACE_Wdir/G13image2

#echo '<br> The P2 and P5 channels can be approximately scaled to the EPHIN P4GM and P41GM rates. <br>We plot the scaled RADMON limits for P4GM and P41GM on the plot.' >> $SPACE_Wdir/G13image2

#echo '<CENTER><IMG SRC="./RADIATION/pgplotI4.gif"></CENTER>' >> $SPACE_Wdir/G13Eimage2

#sec #echo '<ul><li> <a href="ftp://ftp.sec.noaa.gov/pub/lists/pchan/G12pchan_5m.txt">GOES-13 five minute average data.</a><li> <a href="ftp://ftp.sec.noaa.gov/pub/lists/pchan/G12pchan_5m.txt">GOES-10 five minute average data.</a>' >> $SPACE_Wdir/G12image2
#echo '<ul><li> <a href="ftp://www.sec.noaa.gov/pub/lists/pchan/G8pchan_5m.txt">GOES-8 five minute average data.</a><li> <a href="ftp://www.sec.noaa.gov/pub/lists/pchan/G10pchan_5m.txt">GOES-10 five minute average data.</a><li> <a href="ftp://www.sec.noaa.gov/pub/lists/pchan/G11pchan_5m.txt">GOES-11 five minute average data.</a><li> <a href="ftp://www.sec.noaa.gov/pub/lists/pchan/G12pchan_5m.txt">GOES-12 five minute average data.</a>' >> $SPACE_Wdir/G12image2

cat $SPACE_Wdir/G13Eheader $SPACE_Wdir/G13Edata  $SPACE_Wdir/G13Eimage $SPACE_Wdir/G13Efooter >! $WEBdir/G13E.html


endif


