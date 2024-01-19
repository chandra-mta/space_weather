#! /usr/bin/env /usr/local/bin/perl

#############################################################################################
#                                                                                           #
#           run_xmm.perl:    run xmm related scripts                                        #
#               this must be run by run_xmm_wrap_script to set the environment correctly    #
#                                                                                           #
#           author: t. isobe (tisobe@cfa.harvard.edu                                        #
#           last update: Jan 04, 2016                                                       #
#                                                                                           #
#############################################################################################

system("cp /stage/xmmops_ftp/radmon_02h.dat radmon_02h_curr.dat");
#
#--- check whether the file has data points. if there are less than 10 data entries
#--- stop the farther operations
#
open(FH, "./radmon_02h_curr.dat");
$cnt = 0;
while(<FH>){
    $cnt++;
}
close(FH);

if($cnt > 10){
    system("crmreg_cxo");
    system("crmreg_xmm");
    system("/usr/local/bin/idl update");
}
