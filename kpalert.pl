#! /opt/local/bin/perl -w

# Kp warning system for Chandra

# Robert Cameron
# September 2000
# Scott Wolk
# October 2000
# Brad Spitzbart
# January 2001 sim, otg filenames changed. added dom for year change continuity
# April 2001 minor changes to alert scheme and message text
# Aug 2001 exit if kp threshold can not be determined

# THIS PROGRAM CHECKS THE SPACE CRAFT CONFIGURATION
# CALCULATES THE CURRENT KP LIMIT.
# GETS THE CURRENT AIRFORCE KP. 
# COMPARES AND SENDS ALERTS IF NEEDED.
## ALERTS WILL NOT BE SENT IF $FIRST_ALERT DOES NOT EXIST
## $FIRST_ALERT IS DELETED BY THE FIRST ALERT AND MUST BE RECREATED TO 
## REACTIVATE ALERTS.  
#  updated 4/01 BS, ALERTS WILL NOT BE SENT IF $FIRST_ALERT ALREADY EXISTS
#  $FIRST_ALERT IS CREATED BY THE FIRST ALERT AND MUST BE DELETED TO 
#  REACTIVATE ALERTS.  
# CALLS:  /data/mta4/space_weather/calculate_kp.csh
#  THIS IS THE KP WEB GENERATION AND ALERTS MAIL SOURCE
#  HERE WE GET THE KP DATA,  FIND THE FIGURES FOR THE 
#  WEB PAGE AND FORMAT (NOT USED)
#
#  CALLS:  process_kp.nawk WHICH CALCULATES MINS AND MAXS OVER TIME RANGE
#          change line 105 to change limit
#          CALLS: aceviolation_PREDI_Y.csh which pages people when COSTELLO violates yellow limits 
#          CALLS: aceviolation_PREDI_R.csh which pages people when COSTELLO violates red limits 
#          CALLS: aceviolation_ESTKP.csh which pages people when EST Kp violates limits 
#          THESE ARE OBSOLETED BY THE VIOLATIONS SUBROUTINE IN THIS CODE.
#
# TO DO:  move dependency on svirani to taldcroft.

# get the current month and day of year

($sec,$min,$hour,$dum,$mon,$year,$dum,$doy,$dum) = gmtime();
$year += 1900;
$dom = calc_dom($year, $doy+1, $hour, $min, $sec);
$doy += (1 + $hour/24 + $min/1440 + $sec/86400);


#$SIM_file = "/export/acis-flight/FLU-MON/FPHIST.dat";
#$SIM_file = "/export/acis-flight/FLU-MON/FPHIST-$year.dat";
# will use 2001 filename for now, may chance it future per shanil 1/02
# swith to /proj backup, switch back after shanil moves to rhodes 3/26/03 bds
$SIM_file = "/export/acis-flight/FLU-MON/FPHIST-2001.dat";
#$SIM_file = "/proj/sot/acis/FLU-MON/FPHIST-2001.dat";

#$OTG_file = "/export/acis-flight/FLU-MON/GRATHIST.dat";
#$OTG_file = "/export/acis-flight/FLU-MON/GRATHIST-$year.dat";
$OTG_file = "/export/acis-flight/FLU-MON/GRATHIST-2001.dat";
#$OTG_file = "/proj/sot/acis/FLU-MON/GRATHIST-2001.dat";
$GEPH_file = "/proj/rac/ops/ephem/gephem.dat";
$CUR_KP_file = "/data/mta4/space_weather/KPII/current_Kp.txt";
#$FIRST_ALERT = "/data/mta4/space_weather/KPII/prot_ready";
#$FIRST_ALERT = "/pool1/mta/kpalert.out";
$FIRST_ALERT = "/tmp/mta/kpalert.out";

# index the matrix of month-vectors of Kp thresholds by
# orbit leg (Ascending/Descending), OTG config, and SI

$kp{A}{LETG}{ACIS} = [999, 8.3, 8.0, 999, 999, 999, 999, 999, 8.7, 999, 999, 999];
$kp{D}{LETG}{ACIS} = [999, 999, 8.4, 8.1, 999, 999, 999, 999, 7.1, 6.6, 7.4, 8.1];
$kp{A}{HETG}{ACIS} = [999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999];
$kp{D}{HETG}{ACIS} = [999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 8.8, 999];
$kp{A}{NONE}{ACIS} = [8.6, 7.2, 6.9, 999, 999, 999, 999, 9.0, 7.6, 8.7, 999, 999];
$kp{D}{NONE}{ACIS} = [999, 8.7, 7.3, 7.0, 8.5, 8.8, 999, 9.0, 5.0, 5.5, 6.3, 7.0];
		    
$kp{A}{LETG}{HRC}  = [999, 8.3, 8.0, 999, 999, 999, 999, 999, 8.7, 999, 999, 999];
$kp{D}{LETG}{HRC}  = [999, 999, 8.4, 8.1, 999, 999, 999, 999, 7.1, 6.6, 7.4, 8.1];
$kp{A}{HETG}{HRC}  = [999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999];
$kp{D}{HETG}{HRC}  = [999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 8.8, 999];
$kp{A}{NONE}{HRC}  = [8.6, 7.2, 6.9, 999, 999, 999, 999, 9.0, 7.6, 8.7, 999, 999];
$kp{D}{NONE}{HRC}  = [999, 8.7, 7.3, 7.0, 8.5, 8.8, 999, 9.0, 6.0, 5.5, 6.3, 7.0];

#editted decending spetmber ACIS from 6 to 5 after 9/14/01 telecon (SOD)
# read the ephemeris file

open (EF, $GEPH_file) or die "Cannot open gephem.dat\n";
@ephem = split ' ',<EF> ;
$leg = $ephem[1];

# read the SIM file

open(SIMF,$SIM_file) or die "Cannot open $SIM_file\n";
while (<SIMF>) {
    @cols = split;
    @date = split(/:/, $cols[0]);
    $file_dom = calc_dom($date[0], $date[1], $date[2], $date[3], $date[4]);
    last if ($file_dom > $dom);
    @si = split /-/, $cols[1];
    $si = $si[0];
    #$mode =$si[1];
}


# read the OTG file

open(OTGF,$OTG_file) or die "Cannot open $OTG_file\n";
while (<OTGF>) {
    @cols = split;
    @date = split(/:/, $cols[0]);
    $file_dom = calc_dom($date[0], $date[1], $date[2], $date[3], $date[4]);
    last if ($file_dom > $dom);
    $hetg = $cols[1];
    $letg = $cols[2];
}

$otg = "NONE";
$otg = "HETG" if ($hetg =~ /IN/  && $letg =~ /OUT/);
$otg = "LETG" if ($hetg =~ /OUT/ && $letg =~ /IN/ );
$otg = "BAD"  if ($hetg =~ /IN/  && $letg =~ /IN/ );
$simode =$si ."-".$otg;


# find the appropriate Kp threshold

$kp = $kp{$leg}{$otg}{$si};
$kp = @$kp[$mon];
 
# once in a while, some components needed to determine kp threshold are 
#  temporarily unavailable (gephem file is just being written, etc.)
#  In that case just exit.  cron job will try again later.
if (! defined $kp) {
  print "Can not determine Kp threshold for month: $mon, leg: $leg, otg: $otg, si: $si\n";
  print "Kp value not checked.\n";
  exit;
}

#print "$doy $leg $si $simode $otg: Kp threshold = $kp\n";


# GENERATE & READ THE AIR FORCE KP FILE.  Check for violation

system("/data/mta4/space_weather/calculate_kp.csh");
open (EF, $CUR_KP_file) or die "Cannot open current_Kp.txt\n";
@observed_kp = split ' ',<EF> ;
$af_kp = $observed_kp[1];

#print "Observed Air Force Kp = $af_kp\n";

$direction = "descending" if ($leg =~ /D/);
$direction = "ascending" if ($leg =~ /A/);

if ($af_kp > $kp){ #VIOLATION
    if (!-e $FIRST_ALERT) {
      $pos = rindex($FIRST_ALERT, "/");
      $ALERT_DIR = substr($FIRST_ALERT, 0, $pos);
      if (!-d $ALERT_DIR) {
        system("mkdir -p $ALERT_DIR");
      }
      &violation;
    }
    system("date >> $FIRST_ALERT");
  } else { 
     # print "NO VIOLATION\n";
  }

sub send_email {
    @email = qw(sot_yellow_alert);
    foreach (@email) {
	open (MAIL, "| mailx -s 'Kp-ALERT!' $_\n") or die "Cannot send email\n";
	print MAIL $msg;
	close MAIL;
    }
}

sub violation {
# read the DSN schedule

    $DSNsched_file = "/proj/rac/ops/ephem/DSN.sch";
    ($sec,$min,$hour,$dum,$dum,$dum,$dum,$doy) = gmtime();
    $doy += (($sec/60 + $min)/60 + $hour)/24 + 1;
    open(DF,$DSNsched_file) or die "Cannot open $DSNsched_file\n";
    while (<DF>) {
        @cols = split;
        @mydoy = split(/\./, $cols[1]);
        push @c,"UT:$mydoy[0]-$cols[6] $cols[7]\n" if ($doy < $cols[3] && $doy+3 > $cols[3]);
        last if ($#c == 2);
    }

# build and send the alert message

    chomp ($date = `date`);
    $msg  = sprintf "\nALERT!! Kp\n";
    $msg .= sprintf "A Radiation violation of the USAF Kp index has occured.\n";
    $msg .= sprintf "Value = $af_kp (dynamic limit: $kp)\n";
    $msg .= sprintf "see: http://cxc.harvard.edu/mta/ace.html.  We are currently\n";
    $msg .= sprintf  "$direction with $simode at the focal plane.\n";
    $msg .= sprintf "Next DSN contacts:\n @c";
    $msg .= $date;
    &send_email() if (-e "/var/mail");
#    $pal[0]++;
#    if (open AF, ">$alert_file") { print AF "$pal[0]  $tsec  (ACE alert number $
#pal[0], sent at $date)\n" } 
#    else { print STDERR "Cannot write to $alert_file\n"};

####################################
}

sub calc_dom {
  my ($yr, $doy, $hr, $min, $sec) = @_;
  # days since 1999:204:00:00:00
  my $dom = (($yr - 1999)*365) + $doy + $hr/24 + $min/1440 + $sec/86400 - 203;
  # add leap years
  my $first_leap = 2000;
  while ($yr > $first_leap) {
    ++$dom;
    $first_leap += 4;
  }
  return $dom;
}
