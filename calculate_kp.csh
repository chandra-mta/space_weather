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
#


set SPACE_Wdir=/data/mta4/space_weather
set WEBdir=/data/mta4/www


#set file =  http://www.sec.noaa.gov/rpc/costello/ace_pkp_15m.txt
set file =  http://www.swpc.noaa.gov/wingkp/wingkp_list.txt

/opt/local/bin/lynx -source $file | tail -12 >! $SPACE_Wdir/Kp_INDEX.txt



    #run nawkscript to calculate averages and mins
    nawk -F" " -f $SPACE_Wdir/process_kp.nawk $SPACE_Wdir/Kp_INDEX.txt >! $SPACE_Wdir/kpdata

    tail -1 $SPACE_Wdir/kpdata >!  $SPACE_Wdir/KPII/current_Kp.txt

#go and collect Kp image  from costello
#/opt/local/bin/lynx -source http://www.sec.noaa.gov/rpc/costello/pkp_15m_7d.html | tail -9 | head -1 > ! $SPACE_Wdir/tmpkp
#sed s/'<CENTER><IMG SRC="'/''/1 $SPACE_Wdir/tmpkp | sed s/'"><'/' '/1 | sed s/'CENTER>'/''/1 >! $SPACE_Wdir/kpimagename

set image_varkp=`cat $SPACE_Wdir/kpimagename`




#NO WEB FILE THIS TIME
echo '<HR><CENTER><IMG SRC="http://www.swpc.noaa.gov/wingkp/wingkp_15m_7d.gif"></CENTER>' >! $SPACE_Wdir/kpimage
cat $SPACE_Wdir/kpheader $SPACE_Wdir/kpdata  $SPACE_Wdir/kpimage $SPACE_Wdir/rob1 $SPACE_Wdir/footer >! $WEBdir/kp.html





