#! /opt/local/bin/perl -w

use lib '/home/mta/PERL';
use Statistics::Descriptive::Discrete;

$infile="/data/mta4/space_weather/G11pchan";
$P2_lim=300.0/3.3;
$P5_lim=8.47/12.0;

#$lockfile="/pool1/mta/G11pchan_viol.out";
$lockfile="/tmp/mta/G11pchan_viol.out";

open (IN,"<$infile") || die "Cannot open $infile\n";

my $i=0; # indexer
my @jday;  # julian day
my @secs;  # seconds of the day
my @p2; # pchan 2
my @p5; # pchan 2

while (<IN>) {
  @line=split;
  $jday[$i]=$line[4];
  $secs[$i]=$line[5];
  $p2[$i]=$line[7];
  $p5[$i]=$line[10];
  $i++;
} # while (<IN>) {

my $stats = new Statistics::Descriptive::Discrete;
$stats->add_data(@p2);
$p2_med=$stats->median();

$stats = new Statistics::Descriptive::Discrete;
$stats->add_data(@p5);
$p5_med=$stats->median();
#print @p2;
#print "\nHey $p2_med $p5_med\n";
$curr_time = &time_now();

# check that data is current
$last_mjd = $jday[$i-1]+($secs[$i-1]/86400);
$last_time =  `/home/arots/bin/axTime3 $last_mjd u m u s`;
$time_diff = $curr_time-$last_time;
#print "$last_time $curr_time $time_diff\n"; # debug

if ($time_diff < 1200 && ($p2_med > $P2_lim || $p5_med > $P5_lim)) {
  if (!-s $lockfile) { # if an alert hasn't been sent, send one
    if (!-d "/tmp/mta") { `mkdir /tmp/mta`;}
    open (OUT,">$lockfile");
    if ($p2_med > $P2_lim) {
      print OUT "A Radiation violation of GOES 11 P2 (4-9 MeV) has occurred indicating a probable EPHIN P4GM trip.\n";
      printf OUT " Value: %6.2f p/cm2-s-sr-MeV\n",$p2_med;
      printf OUT " Limit: %6.2f\n", $P2_lim;
    }
    if ($p5_med > $P5_lim) {
      print OUT "A Radiation violation of GOES 11 P5 (40-80 MeV) has occurred indicating a probable EPHIN P41GM trip.\n";
      printf OUT " Value: %6.2f p/cm2-s-sr-MeV\n",$p5_med;
      printf OUT " Limit: %6.2f\n", $P5_lim;
    }
    close OUT;
    `cat $lockfile | mailx -s "GOES Alert" brad`;
    #`cat $lockfile | mailx -s "GOES Alert" sot_yellow_alert 6172573986\@mobile.mycingular.com`;
  } else { # if (!-s $lockfile) { # if an alert hasn't been sent, send one
    `date >> $lockfile`;  # touch $lockfile
  }
} # if ($p2_med ge $P2_lim || $p5_med ge $P5_lim) {
#end

sub time_now {
  use Time::TST_Local;
  my $t1998 = 883612800.0;
  my @now = gmtime();
  return (timegm(@now) - $t1998);
}

