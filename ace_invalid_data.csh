#! /bin/tcsh -f
#this rearms the system 24 at the midnight following the last violation -SJW
# 11/03/03 BDS alert if no valid ACE data is seen for 2 hours

mkdir /pool1/mta
set lock = "/pool1/mta/prot_data_violate"

    if ( -f $lock) then
      date >> $lock
    else
      echo " No valid ACE data has been seen for 2 hours." >> $lock

      echo "see http://cxc.harvard.edu/mta/ace.html" >> $lock

      echo "This message sent to sot_lead acisdude sodell brad" >> $lock
      cat $lock | mailx -s ACE_data_invalid brad\@head.cfa.harvard.edu,sot_lead\@head.cfa.harvard.edu,acisdude\@head.cfa.harvard.edu,steve.odell\@msfc.nasa.gov
      cat $lock | mailx -s ACE_data_invalid 6172573986\@mobile.mycingular.com
    endif

#end
