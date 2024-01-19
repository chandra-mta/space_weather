#! /opt/local/bin/perl -w

# BDS 10/26/01  List current S/C info
#               alt, si, grat, comm schedule

  # get s/c info
  $top = (open SF, '/pool14/chandra/chandra1.snapshot')? <SF> : '';
  close SF;
  chomp $top;
  @line = split(/\s+/,$top);
  $alt = $line[-1];
  $dir = chop($alt);
  if ($dir eq 'A') { $dir = 'Ascending';}
  if ($dir eq 'D') { $dir = 'Descending';}
  $top = (open SF, '/proj/rac/ops/CRM/CRMsummary.dat')? <SF> : '';
  close SF;
  chomp $top;
  @line = split(/\s+/,$top);
  $config = $line[-2]." ".$line[-1];

  # get comm schedule
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
  print "Currently $dir through $alt km with $config\n";
  print "Comm schedule:\n";
  print @c;

#end
