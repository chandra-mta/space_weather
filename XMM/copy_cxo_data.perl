#!/usr/bin/perl 

#############################################################################
#                                                                           #
#       copy_cxo_data.perl: copy and modify cxo.gsme_in_Re data             #
#                                                                           #
#           author: t. isobe (tisobe@cfa.harvard.edu)                       #
#           Last update: May 10, 2018                                       #
#                                                                           #
#############################################################################

system("rm -rf ./cxo.gsme_in_Re");
#open(FH, '/proj/rac/ops/ephem/TLE/cxo.gsme_in_Re');
open(FH, ' /data/mta4/proj/rac/ops/ephem/TLE/cxo.gsme_in_Re');
open(OUT, '>./cxo.gsme_in_Re');
#
#--- remove the lines which do not start with digit
#
while(<FH>){
    chomp $_;
    if($_ =~ /nan/){
        next;
    }

    @atemp = split(//, $_);
    if($atemp[0] =~ /\d/){
        print OUT "$_\n";
    }
}
close(OUT);
close(FH);
system("chmod 755 ./cxo.gsme_in_Re");

#
#---------------------------------------------
#

system("rm -rf ./xmm.gsme_in_Re");
open(FH, '/data/mta4/proj/rac/ops/ephem/TLE/xmm.gsme_in_Re');
open(OUT, '>./xmm.gsme_in_Re');
#
#--- remove the lines which do not start with digit
#
while(<FH>){
    chomp $_;
    if($_ =~ /nan/){
        next;
    }

    @atemp = split(//, $_);
    if($atemp[0] =~ /\d/){
        print OUT "$_\n";
    }
}
close(OUT);
close(FH);
system("chmod 755 ./xmm.gsme_in_Re");
