#! /opt/local/bin/perl -w

use lib '/home/mta/PERL';

#$infile="/data/mta4/space_weather/G11pchan";
$infile="/data/mta4/space_weather/G11returned";
$P2_lim=90.9;  # 300/3.3 (P4GM)
$P5_lim=0.70;  # 8.47/12 (P41GM)
#$P2_lim=0.05; #test
#$P5_lim=0.01; #test

if (!-d "/tmp/mta") { `mkdir /tmp/mta`;}
#$lockfile="/pool1/mta/G11pchan_viol.out";
$p2y_lockfile="/tmp/mta/G11pchan_p2y_viol.out";
$p5y_lockfile="/tmp/mta/G11pchan_p5y_viol.out";
$p2r_lockfile="/tmp/mta/G11pchan_p2r_viol.out";
$p5r_lockfile="/tmp/mta/G11pchan_p5r_viol.out";

open (IN,"<$infile") || die "Cannot open $infile\n";

my $i=0; # indexer
my $jday;  # julian day
my $secs;  # seconds of the day
my $p2; # pchan 2
my $p5; # pchan 2

$p2_wait=0;
$p5_wait=0;
$curr_time = &time_now();

while (<IN>) {
  @line=split;
  $jday=$line[4];
  $secs=$line[5];
  $p2=$line[7];
  $p5=$line[10];

  # check that data is current
  $last_mjd = $jday+($secs/86400);
  $last_time =  `/home/arots/bin/axTime3 $last_mjd u m u s`;
  $time_diff = $curr_time-$last_time;
  #print "$last_time $curr_time $time_diff\n"; # debug
  
  # leave enough time for lag in data, but not too much for really stale (or corrupted) data
  if ($time_diff < 3000 && $p2 > $P2_lim) {
    $p2_wait=$p2_wait + 1;
    if (!-s $p2r_lockfile) { # if an alert hasn't been sent, send one
      if ($p2_wait == 5) {
        open (OUT,">$p2r_lockfile") || print "Cannot open $p2r_lockfile\n";
        print OUT "A Radiation violation of GOES 11 P2 (4-9 MeV) has occurred indicating a probable EPHIN P4GM trip.\n";
        printf OUT " Value: %6.2f p/cm2-s-sr-MeV\n",$p2;
        printf OUT " Limit: %6.2f (temp limit for test)\n", $P2_lim;
        close OUT;
        #`cat $p2r_lockfile | mailx -s "GOES Alert" sot_red_alert 6172573986\@mobile.mycingular.com`;
        `cat $p2r_lockfile | mailx -s "GOES Alert TEST" brad`;
      } # if ($p2_wait == 5) {
    } else { # if (!-s $lockfile) { # if an alert hasn't been sent, send one
      `date >> $p2r_lockfile`;  # touch $lockfile
    }
  } else { # if ($time_diff < 1200 && $p2 > $P2_lim) {
    if ($p2_wait > 0) {$p2_wait = $p2_wait - 1;}
  }
  
  if ($time_diff < 3000 && $p5 > $P5_lim) {
    $p5_wait=$p5_wait + 1;
    if (!-s $p5r_lockfile) { # if an alert hasn't been sent, send one
      if ($p5_wait == 5) {
        open (OUT,">$p5r_lockfile");
        print OUT "A Radiation violation of GOES 11 P5 (40-80 MeV) has occurred indicating a probable EPHIN P41GM trip.\n";
        printf OUT " Value: %6.2f p/cm2-s-sr-MeV\n",$p5;
        printf OUT " Limit: %6.2f (temp limit for test)\n", $P5_lim;
        close OUT;
        cat $p5r_lockfile | mailx -s "GOES Alert" sot_red_alert 6172573986\@mobile.mycingular.com`;
        #`cat $p5r_lockfile | mailx -s "GOES Alert TEST" brad`;
      } # if ($p5_wait == 5) {
    } else { # if (!-s $lockfile) { # if an alert hasn't been sent, send one
      `date >> $p5r_lockfile`;  # touch $lockfile
    }
  } else { # if ($time_diff < 1200 && $p5 > $P5_lim) {
    if ($p5_wait > 0) {$p5_wait = $p5_wait - 1;}
  }
} # while (<IN>) {

#end

sub time_now {
  use Time::TST_Local;
  my $t1998 = 883612800.0;
  my @now = gmtime();
  return (timegm(@now) - $t1998);
}

