#! /opt/local/bin/perl -w
# process_ace.nawk --> process_ace.pl
# version 3.0  07 nov 2003 bds
# v3.0 looks at P3 first, 
#        if no good, looks at P5*scaler, 
#        if no good uses P6*scaler
# v3.0 change nawk to perl to do multiple loops

$infile="last45";
#$infile="test45d";
#$infile=$ARGV[0];
open(IN,"<$infile");
while (<IN>) {
  @line=split;
  @ut_yr=(@ut_yr,$line[0]);
  @ut_mo=(@ut_mo,$line[1]);
  @ut_da=(@ut_da,$line[2]);
  @ut_hh=(@ut_hh,$line[3]);
  @de_stat=(@de_stat,$line[6]);
  @de1=(@de1,$line[7]);
  @de4=(@de4,$line[8]);
  @pr_stat=(@pr_stat,$line[9]);
  @pr2=(@pr2,$line[10]);
  @pr3=(@pr3,$line[11]);
  @pr5=(@pr5,$line[12]);
  @pr6=(@pr6,$line[13]);
  @pr7=(@pr7,$line[14]);
  if ($line[6] == 0) { # electron data is valid
    $de1_tot+=$line[7];
    $de4_tot+=$line[8];
  } # if ($line[6] == 0) { # electron data is valid
  if ($line[9] == 0) { # proton data is valid
    $pr2_tot+=$line[10];
    $pr3_tot+=$line[11];
    $pr5_tot+=$line[12];
    $pr6_tot+=$line[13];
    $pr7_tot+=$line[14];
  } # if ($line[9] == 0) { # proton data is valid
} # while (<IN>) {
close IN;

if ($pr3_tot/$pr5_tot >= 1 && $pr3_tot/$pr5_tot < 14) {
  $pr3_col=3;
}  else {
  #if ($pr5_tot/$pr6_tot >= 1 && $pr5_tot/$pr6_tot < 7) {
  if ($pr5_tot/$pr6_tot >= 1 && $pr5_tot/$pr6_tot < 1) {
    $pr3_col=5;
    @pr3=map {7*$_} @pr5;
    $P3_scale="7";  # a string for labels
  } else {
    $pr3_col=6;
    @pr3=map {36*$_} @pr6;
    $P3_scale="36";
    # add send P5/P6 notice here
  }
}
    
print "                                        Most recent ACE observations\n";
print "                               Differential Flux particles\/cm2-s-ster-MeV\n";
print " \n";
print " UT Date   Time    --- Electron keV ---     --------------------- Protons keV -------------------\n";
if ($pr3_col == 3) {
  print "                     DE1         DE4         P2           P3          P5         FP6p         P7\n";
  print "  YR MO DA HHMM     38-53      175-315     65-112      112-187      310-580    761-1220   1060-1910\n";
}
if ($pr3_col == 5) {
  print "                     DE1         DE4         P2       P3scaledP5      P5         FP6p         P7\n";
  print "  YR MO DA HHMM     38-53      175-315     65-112      112-187*     310-580    761-1220   1060-1910\n";
}
if ($pr3_col == 6) {
  print "                     DE1         DE4         P2       P3scaledP6      P5         FP6p         P7\n";
  print "  YR MO DA HHMM     38-53      175-315     65-112      112-187**    310-580    761-1220   1060-1910\n";
}

$ip=0;
$ie=0;
$de1m=1000000.;
$de4m=1000000.;
$pr2m=1000000.;
$pr3m=1000000.;
$pr5m=1000000.;
$pr6m=1000000.;
$pr7m=1000000.;

$pr3_tot=0 ; # must refigure in case we are scaling
for ($i=0;$i<=$#ut_yr;$i++) {
  printf "%4d %2d %2d %4d %11.3f %11.3f %11.3f %11.3f %11.3f %11.3f %11.3f\n", $ut_yr[$i], $ut_mo[$i], $ut_da[$i], $ut_hh[$i], $de1[$i], $de4[$i], $pr2[$i], $pr3[$i], $pr5[$i], $pr6[$i], $pr7[$i];
  if ($de_stat[$i] == 0) {
    $ie++;
    if ($de1[$i] < $de1m) {$de1m = $de1[$i];} # keep track of mins
    if ($de4[$i] < $de4m) {$de4m = $de4[$i];}
  }
  if ($pr_stat[$i] == 0) {
    $ip++;
    if ($pr2[$i] < $pr2m) {$pr2m = $pr2[$i];}
    if ($pr3[$i] < $pr3m) {$pr3m = $pr3[$i];}
    if ($pr5[$i] < $pr5m) {$pr5m = $pr5[$i];}
    if ($pr6[$i] < $pr6m) {$pr6m = $pr6[$i];}
    if ($pr7[$i] < $pr7m) {$pr7m = $pr7[$i];}
    $pr3_tot+=$pr3[$i]; # refigure in case we are scaling
  }
} #for ($i=0;$i<=$#ut_yr;$++) {

if ($ip > 0 && $ie > 0){
  #Calculate averages
  $de1a=$de1_tot/$ie;
  $de4a=$de4_tot/$ie;
  $pr2a=$pr2_tot/$ie;
  $pr3a=$pr3_tot/$ie;
  $pr5a=$pr5_tot/$ie;
  $pr6a=$pr6_tot/$ie;
  $pr7a=$pr7_tot/$ie;

  #calculate 2-hour fluence
  $de1f=$de1a * 7200;
  $de4f=$de4a * 7200;
  $pr2f=$pr2a * 7200;
  $pr3f=$pr3a * 7200;
  $pr5f=$pr5a * 7200;
  $pr6f=$pr6a * 7200;
  $pr7f=$pr7a * 7200;
  
#Calculate Spectral indcies:
  $P5_P6 = $pr5a/$pr6a;
  $P6_P7 = $pr6a/$pr7a;
  $P5_P7 = $pr5a/$pr7a;

#VIOLATION CHECKS:

##CREATE ALERT MESSAGE CALL
#call_alerts  if ($pr3_col == 3) {
#call_alerts    if ($pr3f > 3.6e8) {
#call_alerts      $val = sprintf("%.4e", $pr3f);
#call_alerts      `/data/mta4/space_weather/aceviolation_protons.csh $val`;
#call_alerts    }
#call_alerts  }
#call_alerts  if ($pr3_col == 5) {
#call_alerts    if ($pr3f > 1.2e8) {
#call_alerts      $val = sprintf("%.4e", $pr3f);
#call_alerts      `/data/mta4/space_weather/aceviolation_protonsP5.csh $val`;
#call_alerts    }
#call_alerts  }
#call_alerts  if ($pr3_col == 6) {
#call_alerts    if ($pr3f > 1.2e8) {
#call_alerts      $val = sprintf("%.4e", $pr3f);
#call_alerts      `/data/mta4/space_weather/aceviolation_protonsP6.csh $val`;
#call_alerts    }
#call_alerts  }
  print " \n";
  print " \n";
  print "                        2 hour  Real-time Differential Electron and Proton Flux\n";
  #print "                                 Differential Flux particles/cm2-s-ster-MeV";
  print " \n";
  print "                   --- Electron keV ---     --------------------- Protons keV -------------------\n";
  if ($pr3_col == 3) {
    print "                   DE1         DE4            P2               P3            P5            FP6p           P7\n";
    print "                 38-53       175-315         65-112        112-187         310-580       761-1220      1060-1910\n";
  }
  if ($pr3_col == 5) {
    print "                   DE1         DE4            P2          P3scaledP5         P5            FP6p           P7\n";
    print "                 38-53       175-315         65-112        112-187*        310-580       761-1220      1060-1910\n";
  }
  if ($pr3_col == 6) {
    print "                   DE1         DE4            P2          P3scaledP6         P5            FP6p           P7\n";
    print "                 38-53       175-315         65-112        112-187**       310-580       761-1220      1060-1910\n";
  }

  print "\n";
  printf "%7s %14.3f %14.3f %14.3f %14.3f %14.3f %14.3f %14.3f\n", "AVERAGE", $de1a,$de4a,$pr2a,$pr3a,$pr5a,$pr6a,$pr7a;
  printf "%7s %14.3f %14.3f %14.3f %14.3f %14.3f %14.3f %14.3f\n", "MINIMUM", $de1m,$de4m,$pr2m,$pr3m,$pr5m,$pr6m,$pr7m;
  printf "%7s %14.4e %14.4e %14.4e %14.4e %14.4e %14.4e %14.4e\n", "FLUENCE", $de1f,$de4f,$pr2f,$pr3f,$pr5f,$pr6f,$pr7f;
  print "\n";
  printf "%7s %14s %14.3f %14s %14.3f %14s %14.3f \n", "SPECTRA","P5/P6",$P5_P6,"P5/P7",$P5_P7,"P6/P7",$P6_P7;
  print "\n";
  if ($pr3_col == 6) {
    print "** This P3 channel is currently scaled from P6 data. P3* = P6 X $P3_scale\n";
  }
  if ($pr3_col == 5) {
    print "* This P3 channel is currently scaled from P5 data. P3* = P5 X $P3_scale\n";
  }
} # if ($ip > 0 && $ie > 0){
else {
  print " No Valid data for last 2 hours\n";
  `/data/mta4/space_weather/ace_invalid_data.csh`;
}
