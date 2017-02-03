#!/usr/bin/python

import re
from sys import argv

workload_type = argv[1].strip()
load_factor = float(argv[2])

# read in baseline performance data
baseline_fname = argv[3]
baseline_data = {}
with open(baseline_fname) as f:
    lines = f.readlines()
for line in lines:
    words = [x for x in line.strip().split(' ') if x]
    size = int(words[0])
    baseline_data[size] = (float(words[1]), float(words[2]))

# read in raw data extracted from client*.log
log_fname = argv[4]
with open(log_fname) as f:
    lines = f.readlines()

num_total_messages = 0
raw_data = {}
for line in lines:
    words = [x for x in line.strip().split(' ') if x]
    if words[0] != '@':
        continue
    num_total_messages += 1
    size = int(words[1])
    us = float(words[2])

    if size not in raw_data.keys():
        raw_data[size] = []
    raw_data[size].append(us)

agg_data = {}
for size in raw_data:
    data = sorted(raw_data[size])
    n = len(data)
    median = data[int(n * 0.5) - 1]
    tail = data[int(n * 0.99) - 1]
    agg_data[size] = (n, float(n)/num_total_messages, median, tail)

transport = 'Homa'
for size in sorted(agg_data):
    print transport, workload_type, load_factor, size, agg_data[size][0], agg_data[size][1], agg_data[size][2] / baseline_data[size][0], agg_data[size][3] / baseline_data[size][0]

