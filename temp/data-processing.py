#!usr/bin/python

import re
from sys import argv

fname = argv[1]
with open(fname) as f:
    lines = f.readlines()

# Example line: "echo                 230.9 us     send 9012B message, receive 9012B message median\n"
#median_pat = re.compile("(.*)receive (.*)B message median")
#tail_pat = re.compile("(.*)receive (.*)B message 99%")

median_map = {}
tail_map = {}
for line in lines:
    words = [x for x in line.strip().split(' ') if x]
    if words[-1] == "median" or words[-1] == "99%":
        message_size = int(words[4][:-1])
        time = float(words[1])
        unit = words[2]
        if (unit == "ms"):
            time *= 1000
        elif (unit == "s"):
            time *= 1000000

        if words[-1] == "median":
            median_map[message_size] = time
        else:
            tail_map[message_size] = time

for message_size in sorted(median_map):
    print message_size, median_map[message_size], tail_map[message_size]

