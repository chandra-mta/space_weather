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
#set lock = "./prot_violate"

    if ( -f $lock) then
      date >> $lock
    else
      # send alert -change oct 31, 2003 -SJW
      #P3#echo " A Radiation violation of P3 (130Kev) has been observed by ACE" >> $lock
      echo " A Radiation violation of P5 (337Kev) has been observed by ACE" >> $lock
      echo " Observed = $1" >> $lock
      #P3#echo " (limit = fluence of 3.6e8 particles/cm2-ster-MeV within 2 hours)" >> $lock
      echo " (limit = fluence of 7.2e6 particles/cm2-ster-MeV within 2 hours)" >> $lock

      echo "see http://cxc.harvard.edu/mta/ace.html" >> $lock

      # add current s/c info, if you know how
      if ( -f curr_state.pl) then
        curr_state.pl >> $lock
      endif

      echo "This message sent to sot_red_alert" >> $lock
      #cat $lock | mailx -s ACE_p5 sot_red_alert
      cat $lock | mailx -s ACE_p5_test brad 
    endif

#end
