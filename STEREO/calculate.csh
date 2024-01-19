#! /bin/tcsh -f

set SPACE_Wdir=/data/mta4/space_weather/STEREO
set WEBdir=/data/mta4/www/RADIATION/STEREO2

#set today=`date '+%y%m%d'`

# 01/14/02 BDS -SEC data problems, changed to www.sec.noaa.gov
#   old links marked with #sec
# 11/06/03 BDS - change www.sec.noaa.gov to www.sec.noaa.gov (web farm)
# 11/14/03 BDS - make our own plot, with scaled P3 values
#                old sec plot instructions are commented out
#                with #sec_plot
#
# Oct 21, 2015 - noaa ftp sites and plot link changed  (TI)
# Not 17, 2105 - moved to linux machine

#set file = ftp://ftp.sec.noaa.gov/pub/lists/stereo/sta_impact_5m.txt
set file = ftp://ftp.swpc.noaa.gov/pub/lists/stereo/sta_impact_5m.txt
#/usr/bin/lynx -source $file > $SPACE_Wdir/stereoAdata
wget -q -O $SPACE_Wdir/stereoAdata $file

#set file = ftp://ftp.sec.noaa.gov/pub/lists/stereo/stb_impact_5m.txt
set file = ftp://ftp.swpc.noaa.gov/pub/lists/stereo/stb_impact_5m.txt
#/usr/bin/lynx -source $file > $SPACE_Wdir/stereoBdata
wget -q -O $SPACE_Wdir/stereoBdata $file

set count = `cat $SPACE_Wdir/stereoAdata | wc -l`

if ($count > 28) then 
#
#---go collect STEREO images
#
    #/usr/bin/lynx -source http://legacy-www.swpc.noaa.gov/stereo/data/impact_A_5m_7d.gif >! $WEBdir/impact_A_5m_7d.gif
    wget -q -O $WEBdir/impact_A_5m_7d.gif https://services.swpc.noaa.gov/experimental/images/stereo/impact_A_5m_7d.gif
    #/usr/bin/lynx -source http://legacy-www.swpc.noaa.gov/stereo/data/impact_B_5m_7d.gif >! $WEBdir/impact_B_5m_7d.gif
    #wget -q -O $WEBdir/impact_B_5m_7d.gif http://legacy-www.swpc.noaa.gov/stereo/data/impact_B_5m_7d.gif
#    cat $SPACE_Wdir/header $SPACE_Wdir/stereoAdata  $SPACE_Wdir/imageA $SPACE_Wdir/stereoBdata $SPACE_Wdir/imageB $SPACE_Wdir/footer >! $WEBdir/stereo.html
    cat $SPACE_Wdir/header $SPACE_Wdir/stereoAdata  $SPACE_Wdir/imageA  $SPACE_Wdir/footer >! $WEBdir/stereo.html

endif


