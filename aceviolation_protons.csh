#! /bin/tcsh -f
# supply current fluence as ARGV[1]
#modified 4/4/2001 to write to pool1 instead of $HOME
#this rearms the system 24 at the midnight following the last violation -SJW
# 10/26/01 BDS added state info

#modified 10/25/2001 to  only trigger 1 alert, send it to sot_red and 
#note the time. -SJW

if (! -d /tmp/mta) then
  mkdir /tmp/mta
endif

#set lock = "/pool1/mta/prot_violate"
set lock = "/tmp/mta/prot_violate"
#set block = "/home/mta/Snap/.scs107alert"
set block = "/data/mta4/www/Snapshot/.scs107alert"
#set lock = "./prot_violate"

    if ( -f $lock) then
      date >> $lock
    else
      echo " A Radiation violation of P3 (130Kev) has been observed by ACE" >> $lock
      echo " Observed = $1" >> $lock
      echo " (limit = fluence of 3.6e8 particles/cm2-ster-MeV within 2 hours)" >> $lock

      echo "see http://cxc.harvard.edu/mta/ace.html" >> $lock

      # add current s/c info, if you know how
      if ( -f curr_state.pl) then
        curr_state.pl >> $lock
      endif

      if (! -s $block) then
        #echo "Telecon now on 1-877-521-0441 111165#" >> $lock
        #echo "This message sent to sot_red_alert" >> $lock
        echo "The ACIS on-call person should review the data and call a telecon if necessary. " >> $lock
        echo "This message sent to sot_ace_alert" >> $lock
        #cat $lock | mailx -s "ACE_p3 telecon now" sot_red_alert
        #cat $lock | mailx -s "ACE_p3 " sot_red_alert
        cat $lock | mailx -s "ACE_p3 " sot_ace_alert
        #cat $lock | mailx -s "ACE_p3 telecon now" 6172573986@mobile.mycingular.com
      endif
      if ( -s $block) then
        echo "This message sent to sot_yellow_alert" >> $lock
        cat $lock | mailx -s ACE_p3 sot_yellow_alert
      endif
      #cat $lock | mailx -s ACE_p3_test brad 
    endif

#end
