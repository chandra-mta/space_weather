#! /bin/tcsh -f
# supply current fluence as ARGV[1]
#this rearms the system 24 at the midnight following the last violation -SJW
# 11/03/03 BDS alert if P5 data may be spurious, ie. P5/P6 > threshold

if (!-d /pool1/mta) { `mkdir /pool1/mta`;}
set lock = "/pool1/mta/prot_spec_violate"

    if ( -f $lock) then
      date >> $lock
    else
      echo " A spectral index violation of P5/P6 has been observed by ACE, indicating a possibly invalid P5 channel." >> $lock
      echo " Observed = $1" >> $lock
      echo " (limit = $2)" >> $lock

      echo "see http://cxc.harvard.edu/mta/ace.html" >> $lock

      echo "This message sent to sot_yellow_alert" >> $lock
      cat $lock | mailx -s ACE_p5/p6 sot_yellow_alert
      #cat $lock | mailx -s ACE_p5/p6 brad swolk
    endif

#end
