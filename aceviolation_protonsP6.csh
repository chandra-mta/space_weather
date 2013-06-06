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

#set lock = "/pool1/mta/prot_violateP6"
set lock = "/tmp/mta/prot_violateP6"
set block = "/home/mta/Snap/.scs107alert"
#set lock = "/pool1/prot_violate_test"
#set lock = "./prot_violate"

    if ( -f $lock) then
      date >> $lock
    else
      # send alert -change oct 31, 2003 -SJW
      echo " A Radiation violation of P3 (130keV) scaled from P6 (761keV) has been observed by ACE" >> $lock
      echo " Observed = $1" >> $lock
      #echo " (limit = fluence of 3.6e8 particles/cm2-ster-MeV within 2 hours)" >> $lock
      echo " (limit = fluence of 1.2e8 particles/cm2-ster-MeV within 2 hours)" >> $lock
      echo "see http://cxc.harvard.edu/mta/ace.html" >> $lock

      # add current s/c info, if you know how
      if ( -f curr_state.pl) then
        curr_state.pl >> $lock
      endif

      if (! -s $block) then
        #echo "This message sent to sot_yellow_alert" >> $lock
        #cat $lock | mailx -s ACE_p3_scaled sot_yellow_alert
        cat $lock | mailx -s ACE_p3_scaled brad
      endif
      if ( -s $block) then
        #echo "This message sent to sot_yellow_alert" >> $lock
        #cat $lock | mailx -s ACE_p3_scaled sot_yellow_alert
        cat $lock | mailx -s ACE_p3_scaled brad
      endif
      #cat $lock | mailx -s ACE_p3_scaled brad

    endif

#end
