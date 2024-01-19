#!/usr/bin/env /proj/sot/ska/bin/python

#################################################################################################
#                                                                                               #
#   check_mta_xmm_alert_page.py: check the latest count Il count rate and xmm orbital           #
#                                altitude and send out warning if mta_XMM_alert file            #
#                                does not exist.                                                #
#                                                                                               #
#           author: t. isobe (tisobe@cfa.harvard.edu)                                           #
#                                                                                               #
#           last update: Nov 09, 2015                                                           #
#                                                                                               #
#################################################################################################

import sys
import os
import string
import re
import time
import random
import math

#
#--- reading directory list
#
path = '/data/mta/Script/Python_script2.7/dir_list_py'

f    = open(path, 'r')
data = [line.strip() for line in f.readlines()]
f.close()

for ent in data:
    atemp = re.split(':', ent)
    var  = atemp[1].strip()
    line = atemp[0].strip()
    exec "%s = %s" %(var, line)
#
#--- append path to a private folders
#
sys.path.append(mta_dir)

import mta_common_functions as mcf
import convertTimeFormat    as tcnv

#
#--- temp writing file name
#
rtail  = int(10000 * random.random())       #---- put a romdom # tail so that it won't mix up with other scripts space
zspace = '/tmp/zspace' + str(rtail)

#
#-- convert factor to change time to start from 1.1.1998
#
tcorrect = (28.0 * 365.0 + 8.0) * 3600.0 * 24.0
#
#--- Earth radius and the altitude limit, L1 count rate and output file
#
earth      =  6378.0
alt_limit  = 80000.0 + earth
l1_limit   = 10
alert_file = '/pool1/mta_XMM_alert'

#--------------------------------------------------------------------------
#-- run_test: check the latest count Il count rate and xmm orbital altitude 
#--------------------------------------------------------------------------

def run_test():
    """
    check the latest count Il count rate and xmm orbital altitude and
    send out warning if mta_XMM_alert file does not exist.
    input: none
    output: /pool1/mta_XMM_alert if it does not exist already
            warning eamil
    """
#
#--- find the latest 30 mins of l1 average and their time span as there are
#--- often slight delay in time in the data aquisition
#
    [l1, start, stop] = l1_average()
#
#--- read xmm altitude data
#
    [atime, alt]      = read_xmm_orbit()
#
#--- if the altitude of the satellite is lower then "alt_limit" during the time period,
#--- condtion is not met; stop the program
#    
    height = 0
    for i in range(0, len(atime)):
        if atime[i] < start:
            continue

        elif atime[i] > stop:
            break

        else:
            if alt[i] > height:
                height = alt[i]
                stime  = atime[i]
#
#--- keep the record
#
    r_time = 0.5 * (start + stop)
    stime  = tcnv.convertCtimeToYdate(r_time)
    line   =  str(stime) + ' : ' + str(r_time) + '\t\t' + str(round(l1,1)) + '\t\t' + str(round(height,1)) + '\n'
    fo     = open('./l1_alt_records', 'a')
    fo.write(line)
    fo.close()

    if l1 < l1_limit:
        exit(1)

    if height < alt_limit:
        exit(1)
#
#--- both conditions are met; check alert file already exists
#
#
#--- keep the record of alert time
#
    keep_record(stime, height, l1)
    go = 0
#
#--- file does not exist
#
    if mcf.chkFile(alert_file) == 0:
        go = 1
#
#--- file was created more than 18 hrs ago.
#
    else:
        if check_time_span(alert_file, 64800):
            go = 2
#
#--- if the file does not exist or more than 18 hrs past after creating the file,
#--- create/recreate the file and also send out a warning email.
#
    if go > 0:
#
#--- read the last 30 mins of data
#
        f     = open('./l1_alt_records', 'r')
        adata = [line.strip() for line in f.readlines()]
        f.close()

        dline = ''
        dlen  = len(adata)
        for i in range(dlen-6, dlen):
            dline = dline + adata[i] + '\n'
#
#--- alt in kkm
#
        chigh = round((height/1000.0), 3)
#
#--- create email content
#
        line = 'Test threshold crossed, Altitude = ' + str(chigh) + ' kkm with '
        line = line + 'L1 30 min average counts @ ' + str(round(l1,2)) + '.'

        line = line + '\n\n\n'
        line = line + 'Time                (sec)          L1 cnt      Alt\n'
        line = line + '------------------------------------------------------\n'
        line = line + dline
        line = line + '\n\n\n'

        line = line + 'see:\n\n '  
        line = line + '\t\thttps://cxc.cfa.harvard.edu/mta/RADIATION/XMM/ '
        line = line + '\n\nfor the current condition.\n'

        fo   = open(zspace, 'w')
        fo.write(line)
        fo.close()

        cmd = 'cat ' + zspace + '|mailx -s\"Subject: mta_XMM_alert (TEST)\n\" swolk@cfa.harvard.edu' 
        os.system(cmd)
        cmd = 'cat ' + zspace + '|mailx -s\"Subject: mta_XMM_alert (TEST)\n\" tisobe@cfa.harvard.edu' 
        os.system(cmd)

        cmd = 'rm ' + zspace
        os.system(cmd)
#
#--- create/renew alert_file
#
        mcf.rm_file(alert_file)

        file  = alert_file
        fo    = open(file, 'w')
        fo.close()

#--------------------------------------------------------------------------
#-- read_xmm_orbit: read xmm orbital elements and return list of distance to XMM 
#--------------------------------------------------------------------------

def read_xmm_orbit():
    """
    read xmm orbital elements and return list of distance to XMM
    input: none but read from /data/mta4/proj/rac/ops/ephem/TLE/xmm.spctrk
    output: [time, alt] time in seconds from 1998.1.1
                        alt  in km from the center of the Earth
    """
#
#--- read xmm orbital elements
#
    cxofile = "/data/mta4/proj/rac/ops/ephem/TLE/xmm.spctrk"
    f       = open(cxofile, 'r')
    data    = [line.strip() for line in f.readlines()]
    f.close()

    atime = []
    alt  = []
    chk  = 0
    for ent in data:
        atemp = re.split('\s+', ent)
        if mcf.chkNumeric(atemp[0]) == False:
           continue 
#
#--- compute the distance to xmm from the center of the earth
#
        try:
            x = float(atemp[6])
        except:
            continue

        y    = float(atemp[7])
        z    = float(atemp[8])

        dist = math.sqrt(x * x + y * y + z * z)
        alt.append(dist)
#
#--- convert time to seconds from 1998.1.1
#
        atime.append(float(atemp[0])- tcorrect)

    return[atime, alt]

#--------------------------------------------------------------------------
#-- l1_average: find the l1 average count rate for the given time period  -
#--------------------------------------------------------------------------

def l1_average():
    """
    find the l1 average count rate for the given time period
    input:  none but read from: /data/mta4/space_weather/XMM/xmm.archive
    output: avg     --- averge of L1 over the given time period
            start   --- data period stating time in seconds from 1998.1.1
            stop    --- data period ending time in seconds from 1998.1.1
    """
#
#--- read the data
#
    file = '/data/mta4/space_weather/XMM/xmm.archive'
    f    = open(file, 'r')
    data = [line.strip() for line in f.readlines()]
    f.close()
#
#--- reverse the data so that we can read from the latest count
#
    rdata  = list(reversed(data))
#
#--- collect the data between start and stop and take l1 average
#
    sum    = 0
    cnt    = 0
    chk    = 0
    for ent in rdata:
        atemp = re.split('\s+', ent)
#
#--- check the line has a correct entry format 
#
        if len(atemp) != 8:
            continue
        try:
            atime = float(atemp[0])
            l1    = float(atemp[2])
        except:
            continue
#
#--- find the time of the first entry (last recoreded entry)
#--- and set the starting time 30 min before that
#
        if chk == 0:
            stop  = atime
            start = stop - 1800
            chk   = 1

        if atime < start:
            break

        sum += l1
        cnt += 1

    avg = sum / cnt

    return [avg, start, stop]

#--------------------------------------------------------------------------
#-- check_time_span: check whether the file was created more than or equal to a given time period
#--------------------------------------------------------------------------

def check_time_span(file, tspan):
    """
    check whether the file was created more than or equal to a given time period .
    input:  file    --- a file name
            tspan   --- time span in seconds
    output: True or False
    """

    try:
#
#--- time.time creates the current time
#--- st_ctime extracts the file creation time.
#
        diff = time.time() - os.stat(file).st_ctime
    except:
        diff = 0
#
#--- check the file is older than tspan seconds
#
    if diff >= tspan:
        return True
    else:
        return False
    
#--------------------------------------------------------------------------
#-- keep_record:  keep a record of alert time                            --
#--------------------------------------------------------------------------

def keep_record(time, alt, l1):
    """
    keep a record of alert time
    input:  time    --- alert time
            alt     --- altitude of the xmm of the alert time
            l1      --- 30 min average of l1 rate prior to the alert
    """

    chigh = round((alt/1000.0), 3)

    line = 'Test threshold crossed, Altitude = ' + str(chigh) + ' kkm with '
    line = line + 'L1 30 min average counts @ ' + str(round(l1,2)) + '.\n'
    fo   = open(zspace, 'w')
    fo.write(line)
    fo.close()

    cmd = 'cat ' + zspace + '|mailx -s\"Subject: mta_XMM_alert (TEST 2)\n\" tisobe@cfa.harvard.edu' 
    os.system(cmd)

    fo = open('/data/mta4/space_weather/XMM/alt_trip_records', 'a')
    line = str(time) + ': ' + str(chigh) + '\t\t' + str(l1) + '\n'
    fo.write(line)
    fo.close()


#--------------------------------------------------------------------------
#-- current_time: find current time in seconds from 1998.1.1             --
#--------------------------------------------------------------------------

def current_time():
    """
    THIS FUNCTION IS NOT USED IN THIS SCRIPT ANYMORE

    find current time in seconds from 1998.1.1
    input:  none
    output: dtime   --- the current time in seconds from 1998.1.1
    """

    stime  = time.time()
    out    = time.gmtime()
    stime -= tcorrect
    ct     = str(out[0]) + ':' + str(out[7]) + ':' + str(out[3]) + ':' + str(out[4]) + ':' + str(out[5])
    dtime  = tcnv.axTimeMTA(ct)

    return dtime


#--------------------------------------------------------------------------

if __name__ == "__main__":

    run_test()
