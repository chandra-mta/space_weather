#! /usr/bin/perl -w

# ACE particle fluence monitoring system for Chandra.
# Maintain both a data archive and a fluence dataset. 

# Robert Cameron
# November 1999

$SPACE_file = 'ftp://mussel.srl.caltech.edu/pub/ace/browse/EPAM/EPAM_quicklook.txt';
$RACE_file = './ace_fast.archive';
$ephem_file = '/data/mta4/proj/rac/ops/ephem/gephem.dat';
$fluence_file = '/data/mta4/space_weather/ACE/fluace_fast.dat';
$fluence_file = './x';
$fluence_file_bak = './fluace.dat.good';
$fluence_archive = './fluace_fast.arc';
$falert_file = '/data/mta4/proj/rac/ops/ACE/falert.dat';

#$rmin = 70000;        # integrate fluence above this Chandra geocentric distance (km)
$rmin = 10000;        # changed 03/24/11 bds
$delt = 3*86400;      # the depth of ACE archive ($RACE_file) in seconds
$sampl = 300;         # ACE sample time (seconds)

($sec,$min,$hour,$day,$mon,$year,$dum,$doy,$dum) = gmtime();
$year += 1900;
$doy++;
$mon++;
$sod = $hour * 3600 + $min * 60 + $sec;

# fetch the current ACE file

#$/ = "\cM\cJ";        # the Windows-based ACE line terminator

$c = `lynx -source $SPACE_file`;
#$c = `/usr/bin/lynx -source $SPACE_file`;
die scalar(gmtime)." No current ACE data found in $SPACE_file\n" if (length($c) < 3000);
@c = split m!$/!, $c;
@ch = grep { /^#/ } @c;
@cn = grep { /^\d/ } @c;
die scalar(gmtime)." No current ACE data found in $SPACE_file\n" if (!@c or !@ch or !@cn or $#c < 10 or $#ch < 10 or $#cn < 10);

#$/ = "\n";           # restore the usual line terminator

# read the 3-day archive ACE file

open (AF, $RACE_file) or die scalar(gmtime)." Archive ACE file $RACE_file not found!\n";
@a = <AF>;
@an = grep { m/^\d/ } @a;
die scalar(gmtime)." No archive ACE data found in $RACE_file\n" if (!@a or !@an or $#a < 10 or $#an < 10);

# read the fluence file

print $c;
#####open (FF, $fluence_file) or print scalar(gmtime)." ACE fluence file $fluence_file not found!\n";
open (FF, $fluence_file_bak) or die scalar(gmtime)." ACE fluence file $fluence_file not found!\n";
@ff = <FF>;
chomp @ff;
@fh = grep { /^#/ } @ff;
@fn = grep { /^\d/ } @ff;
die scalar(gmtime)." No ACE fluence data found in $fluence_file\n" if (!@ff or !@fh or !@fn or $#ff < 4 or $#fh < 1 or $#fn < 1);
$f = $fn[0];
@fl = split ' ',$fn[-1];

# read the ephemeris file

open (EF, $ephem_file) or die scalar(gmtime)." Ephemeris file $ephem_file not found!\n";
@e = split ' ',<EF>;
die scalar(gmtime)." No ephemeris data found in $ephem_file\n" if (!@e or $#e < 5);
$r = $e[0];

# when the altitude falls below $rmin,
# - archive the orbital fluence
# - reset the alert counter file

if ($fl[-1] > 0 && $r < $rmin) {
    open (AL, ">>$fluence_archive") or die scalar(gmtime)." Cannot append to ACE fluence archive $fluence_archive\n";
    print AL "$fn[-1]\n";
    open (ALTF, ">$falert_file") or die scalar(gmtime)." Cannot write to ACE alert counter file $falert_file\n";
    print ALTF "0 0\n";
}

# find the latest good flux record in the current ACE data
# NOTE: status flags are not reliable. All fluxes must be positive.

foreach (reverse @cn) {
    @g = split;
    if (!$g[6] && !$g[9] && $g[7] > 0 && $g[8] > 0 && 
        $g[10] > 0 && $g[11] > 0 && $g[12] > 0 && $g[13] > 0 && $g[14] > 0) { $f = $_; last };
}

# calculate fluences; build the fluence record

@f = split ' ',$f;
splice @f,6,1;
splice @f,8,1;
foreach $i (6..12) { $fl[$i] += $f[$i]*$sampl if ($f[$i] > 0); $fl[$i] = 0 if ($r < $rmin)};
if ($r > $rmin) { $fl[13] += $sampl } else { @fl[4,5,13] = ($doy,$sod,0) }; 
$fl = sprintf "%4d%3d%3d%4.2d%2.2d %7d %7d %13.0f %12.0f %13.0f %12.0f %12.0f %11.0f %10.0f %6d",
	     $year,$mon,$day,$hour,$min,@fl[4..13];

# write the ACE fluence file

if ($fl && $f && @fh) {
    open (FF, ">$fluence_file") or die scalar(gmtime)." Cannot write to ACE fluence file $fluence_file\n";
    print FF "Latest valid ACE flux data...\n";
    foreach (@ch[-3..-1]) { print FF "$_\n" };
    print FF "$f\n";
    print FF "Fluence data...    Start DOY,SOD",' 'x91,"Int(s)\n";
    print FF "$fl\n";
} else { die scalar(gmtime)." No data to written to ACE fluence file $fluence_file\nData records:\n*$f*\n*$fl*\n" };

# now work on the ACE archive....
# merge the archive and current ACE data into a hash keyed by time

$rl = length $cn[0];
foreach (@an,@cn) {
    @b = split;
    $k = sprintf "%5.5d.%5.5d",$b[4],$b[5];
    $h{$k} = substr $_,0,$rl;
}

# extract the flux data and status from the hash

@k = reverse sort keys %h;
foreach (0 .. $#k) {
    @b = split ' ',$h{$k[$_]};
    push @p, $b[11];
    push @s, $b[9];
}

# linearly interpolate or extrapolate missing flux measurements.
# NOTE: cannot rely on proton status value: also replace "valid" negative proton fluxes.

$v = -1;
foreach (0 .. $#s) { if (!$s[$_] && $p[$_] > 0) { $v = $_ } else { $l{$_} = $v } };
die scalar(gmtime)." No valid ACE data found!\n" if ($v == -1);
$v = -1;
foreach (reverse 0 .. $#s) { if (!$s[$_] && $p[$_] > 0) { $v = $_ } else { $u{$_} = $v } }; 
if (%l) {
    foreach (keys %l) {
        if ($l{$_} == -1) { $p[$_] = $p[$u{$_}] } elsif ($u{$_} == -1) { $p[$_] = $p[$l{$_}] } 
        else { $p[$_] = $p[$l{$_}] + ($_ - $l{$_}) * ($p[$l{$_}] - $p[$u{$_}])/($l{$_} - $u{$_}) };
    }
}

# calculate backwards-integrating fluences

foreach (0 .. $#p) { 
    $s += $p[$_];
    $f[$_] = $s * $sampl;
}

# delete old data from the archive dataset

@kp = split /\./,$k[0];
$kp[0] -= int($delt/86400);
$kp[1] -= ($delt % 86400);
if ($kp[1] < 0) { $kp[0]--; $kp[1] += 86400 };
$kt = sprintf "%5.5d.%5.5d",$kp[0],$kp[1];
@k = grep { $_ ge $kt } @k;

# write the ACE archive file

if ($#k > 0 && $#k >= $#cn) {
    open (AF, ">$RACE_file") or die scalar(gmtime)." Cannot open $RACE_file archive ACE file!\n";
    $ch[-3] .= " Interpol   Fluence";
    $ch[-2] .= "   112-187   112-187";
    $ch[-1] .= "--------------------";
    foreach (@ch) { print AF "$_\n" };
    foreach (0 .. $#k) { printf AF "%s  %.2e  %.2e\n",$h{$k[$_]},$p[$_],$f[$_] };
} else { die scalar(gmtime)." No data to written to $RACE_file ACE archive file!\n" };
