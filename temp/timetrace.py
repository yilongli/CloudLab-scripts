#!/usr/bin/python

import re
from sys import argv

fname = argv[1]
with open(fname) as f:
    lines = f.readlines()

seq_pat = re.compile("received ALL_DATA, sequence (.*),")
ns_pat = re.compile(": (.*) ns \(")

i = 0
records = []
while i < len(lines):
    line = lines[i];
    i += 1
    result = seq_pat.search(line)
    if result is not None:
        # trace back to when the driver received the packets
        j = i - 1;
        while lines[j].find("DpdkDriver received ") < 0:
            j -= 1
        start_line = lines[j]
        start_time = float(ns_pat.search(start_line).group(1))

        sequence = result.group(1)
        while i < len(lines) and lines[i].find("sent data, sequence %s" % sequence) < 0:
            i += 1
        if i == len(lines):
            break
        end_line = lines[i]
        stop_time = float(ns_pat.search(end_line).group(1))
        i += 1
        records.append((stop_time - start_time, sequence))

records = sorted(records)
num_records = len(records)
print "min: %.2d" % records[0][0]
print "50%%: %.2d" % records[int(num_records * 0.5)][0]
print "90%%: %.2d" % records[int(num_records * 0.9)][0]
print "99%%: %.2d" % records[int(num_records * 0.99)][0]
print "99.9%%: %.2d" % records[int(num_records * 0.999)][0]
print records[-100:]
