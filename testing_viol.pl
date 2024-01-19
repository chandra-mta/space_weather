#! /usr/bin/perl -w

$infile = "/data/mta4/space_weather/ace_12h_archive";
$archive_length_lim = 144; # 144 * 5min = 12h

$lockdir = "/tmp/mta";
if (!-d $lockdir) { `mkdir $lockdir`;}
$lockfile = "$lockdir/ace_12h_viol.out";

open (IN,"<$infile") || die "Cannot open $infile\n";

$bad_e_data = 0;  # number of lines with e status != 0
$bad_p_data = 0;  # number of lines with p status != 0

while (<IN>) {
    @line = split;
    # electrons
	print "$line[0] \n";
    if ($line[6] != 0) {
        $bad_e_data = $bad_e_data + 1;
    }
    # protons
    if ($line[9] != 0) {
        $bad_p_data = $bad_p_data + 1;
    }
}

# Do not send alerts between midnight and 7am
$hour_now = (localtime)[2];
if (($hour_now < 24.) && ($hour_now > 7.)) {
    if (($bad_e_data == $archive_length_lim) || ($bad_p_data == $archive_length_lim)) {
        # No valid data for 12h, send out an alert if it has not been sent out yet
        if (-e $lockfile) {
             `date >> $lockfile`;  # touch $lockfile
        } else {
            #open (OUT,">$lockfile") or die "Cannot open $lockfile\n";
            #print OUT "No valid ACE data for at least 12h\n";
            #print OUT "Radiation team should investigate\n";
            #print OUT "This message sent to sot_ace_alert\n";
            #close OUT;
            #`cat $lockfile | mailx -s "ACE no valid data for >12h" sot_ace_alert\@cfa.harvard.edu`;
            # `cat $lockfile | mailx -s "ACE no valid data for >12h" msobolewska\@cfa.harvard.edu swolk\@cfa.harvard.edu`;
            # Store the 12h archive that triggered the alert
            #`cp $infile "$lockdir/ace_12h_archive_alert"`;
        }
    }
}
