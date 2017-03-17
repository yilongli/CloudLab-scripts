#!/bin/bash

# References:
# 1. https://wiki.fd.io/view/VPP/How_To_Optimize_Performance_(System_Tuning)
# 2. http://www.breakage.org/2013/11/15/nohz_fullgodmode/

# Set CPU scaling governor to "performance"
commands="sudo cpupower frequency-set -g performance;"
# Mount hugepages, disable THP(Transparent Hugepages) daemon
commands+="sudo hugeadm --create-mounts --thp-never;"
# TODO: IRQ affinity, cpu shielding via cset, etc.

# Enable Perf to resolve kernel symbols from userspace(?)
commands+="sudo sysctl -w kernel.kptr_restrict=0 kernel.perf_event_paranoid=1"
# Looks like setting kernel.perf_event_paranoid=-1 or running as sudo will make
# task as simple as "perf record -e intel_pt// ls" getting into infinite loop...?
#commands+="sudo sysctl -w kernel.kptr_restrict=0 kernel.perf_event_paranoid=-1"

pdsh -w ^/shome/rc-hosts.txt -x rcnfs "$commands"
