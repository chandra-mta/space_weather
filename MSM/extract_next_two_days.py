#!/usr/bin/env /data/mta/Script/Python3.8/envs/ska3-shiny/bin/python

#################################################################################
#                                                                               #
#   extract_next_three_days.py: extract gse/gsm data for the next two days      #
#                                                                               #
#           author: t. isobe (tisobe@cfa.harvard.edu)                           #
#                                                                               #
#           last update: May 21, 2018                                           #
#                                                                               #
#################################################################################

import sys
import os
import string
import re
import time
import Chandra.Time

#
#---- read PE.EPH.gsme_in_Re and select out the potion that contains the
#---- data from today to the end of 2nd day from today
#---- output: ./gs_data_3_day
#

stday = time.strftime("%Y:%j", time.gmtime())
chk   = float(time.strftime("%H", time.gmtime()))
if chk < 12:
    stday = stday + ':00:00:00'
else:
    stday = stday + ':12:00:00'

start = Chandra.Time.DateTime(stday).secs
stop  = start + 2.0 * 86400.0

f     = open('/data/mta4/proj/rac/ops/ephem/PE.EPH.gsme_in_Re', 'r')
data  = [line.strip() for line in f.readlines()]
f.close()

fo = open('./gs_data_2_day', 'w')

for ent in data:
    atemp = re.split('\s+', ent)
    atime = float(atemp[0])
    if atime < start:
        continue
    elif atime > stop:
        break
    else:
        line = ent + '\n'
        fo.write(line)

fo.close()
