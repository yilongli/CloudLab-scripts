#!/bin/bash
# TODO: HOW TO PASS `--dpdkPort 1` as additional args?
python -m pdb /shome/RAMCloud/scripts/clusterperf.py --transport basic+dpdk --servers 4 --numBackupDisks 1 --replicas 0 --verbose --disjunct basic
