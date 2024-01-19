#! /bin/tcsh -f
#
#  THIS SCRIPT MONITORS USEAGE OF /VAR AND /TMP ON PSICORP
# 
#
#
#  CALLS:  
#
cd /var
/usr/bin/du -sk .[0-9a-zA-Z]* [0-9a-zA-Z]* | sort -nr
df -k .
cd /tmp
/usr/bin/du -sk .[0-9a-zA-Z]* [0-9a-zA-Z]* | sort -nr
df -k .

