#!/bin/bash
PERF=/shome/tools/perf/perf
sudo $PERF record -a -e intel_pt// -S0x8000 sleep 10 &
SUDOPID=$!
while [ -z "$PERFPID" ]; do
    PERFPID=`ps --ppid $SUDOPID -o pid=`
done
sudo ./user_loop $PERFPID
wait # Wait for `perf record` to finish
sudo $PERF script --itrace=i0nsxe -F time,comm,cpu,ip,sym,asm,flags --ns > perf-script-cpu.txt
