#!/bin/bash

# Set CPU scaling governor to "performance"
commands="sudo cpupower frequency-set -g performance;"
# Mount hugepages, disable THP(Transparent Hugepages) daemon
commands+="sudo hugeadm --create-mounts --thp-never;"

# TODO: IRQ affinity

pdsh -w ^/shome/rc-hosts.txt -x rcnfs "$commands"
