#! /usr/bin/perl -w

$infile = "/data/mta4/space_weather/G13data";
$goes_hrc_proxy_lim = 195000;  # Hz ~ 3 x SCS107 trip limit (= 3 x 256 x 248)

$lockdir = "/tmp/mta";
if (!-d "$lockdir") { `mkdir $lockdir`;}
$lockfile = "$lockdir/goes_hrc_proxy_viol.out";

open (IN,"<$infile") || die "Cannot open $infile\n";

$goes_hrc_proxy = 0;
$i = 0;

while (<IN>) {
    if (!($_ =~ /^\d/)) {
        next;
    }
    $i = $i + 1;
    @line = split;
    $goes_hrc_proxy = $line[-1];
    if ($goes_hrc_proxy > $goes_hrc_proxy_lim) {
        # Send out an alert if it has not been send out yet
        if (-e $lockfile) {
            `date >> $lockfile`;
        } else {
            open (OUT,">$lockfile") || print "Cannot open $lockfile\n";
            print OUT "A Radiation violation of G13 HRC shield rate proxy has been observed\n";
            print OUT "Observed = $goes_hrc_proxy Hz (limit = 195000 Hz)\n";
            print OUT "see http://cxc.cfa.harvard.edu/mta/G13.html\n";
            print OUT "This message sent to sot_ace_alert\n";
            close OUT;
            `cat $lockfile | mailx -s "GOES HRC proxy" sot_ace_alert\@cfa.harvard.edu`;
        }
    }
}
