#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import re
import time

today = time.strftime("%Y-%m-%d")
cwd = os.getcwd()
src = os.path.join(cwd, 'src')
log = os.path.join(cwd, 'log', today)
js = re.compile('(.+).(js)')
logs = []

if not(today in os.listdir(os.path.join(cwd, 'log'))):
    os.makedirs(log)

for f in os.listdir(src):
    mo = js.search(f)
    try:
        if mo.group(2) == 'js':
            logfile = 'log/%s/%s.log' % (today, mo.group(1))
            logs.append(logfile)
    except AttributeError:
        continue

for f in logs:
    if not(f in os.listdir(log)):
        open(f, 'w').close()
