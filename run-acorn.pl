#!/opt/local/bin/perl -w

# check that my acorn process is running
# if not, restart and log the process id

# Robert Cameron
# April 2000
# Modified for SWOLK by swolk
# June 2000


$uid = "swolk";
$pid_file = "/data/mta4/space_weather/sacorn.pid";
$work_dir = "/data/mta4/space_weather";
#$acorn_exe = "/home/ascds/DS.release/bin/acorn";
#$acorn_exe = "/data/mta2/pallen/acorn-1.33/acorn";
$acorn_exe = "/data/mta1/pallen/acorn-1.5/acorn";
$UDP_port = "11150";
#$msids = "$work_dir/chandra-msids.list";
#$filesize = 1500;

# set environment variables for acorn

$ENV{ASCDS_CONFIG_MTA_DATA} = '/data/mta2/pallen/acorn/groups';
$ENV{IPCL_DIR} = '/data/mta4/IPCL/P007';
$ENV{ACORN_GUI} = '/data/mta2/pallen/acorn-1.3/scripts';
$ENV{MTA_ALERT_SPOOL} = '/tmp/swolk/mtamail/in';
$ENV{MTA_ALERT_COUNTER} = '/home/swolk/.notifierrc';


# check if the alerts directory still exists, if not rebuild it
$MTA_ALERT_SPOOL_DIR1 = "/tmp/swolk";
$MTA_ALERT_SPOOL_DIR2 = "/tmp/swolk/mtamail";
$MTA_ALERT_SPOOL_DIR = "/tmp/swolk/mtamail/in";
    if (-e $MTA_ALERT_SPOOL_DIR) {
	#print "$MTA_ALERT_SPOOL_DIR exists\n";
    } else { 
	    system("mkdir $MTA_ALERT_SPOOL_DIR1");
	    system("mkdir $MTA_ALERT_SPOOL_DIR2");
	    system("mkdir $MTA_ALERT_SPOOL_DIR");
	}

chdir $work_dir or die "Cannot cd to $work_dir\n";

# get the PID for the last known acorn process

open (PIDF, "+<$pid_file") or die "Cannot open PID file $pid_file\n";
while (<PIDF>) { @pinfo = split };

# get the PID for the currently running acorn process (if any)

@p = `/usr/bin/ps -f -u $uid`;
@a = grep /$acorn_exe/, @p;
if (!@a) {
    #system("$acorn_exe -u $UDP_port -C $msids -e $filesize -nv &");
    system("$acorn_exe -au $UDP_port &");
    print "Acorn process not found: restarting\n";
    sleep 3;
}

@p = `/usr/bin/ps -f -u $uid`;
@a = grep /$acorn_exe/, @p;
die "Cannot find or restart acorn process\n" if (!@a);

foreach (@a) {
    @f = split;
    $pid = $f[1];
}

# compare the actual and expected PIDs. Log any change.

if ($pinfo[0] ne $pid) {
    $date = `date`;
    print "Acorn PID mismatch. Adding pid $pid to $pid_file at $date";
    print PIDF "$pid started at $date";
}
