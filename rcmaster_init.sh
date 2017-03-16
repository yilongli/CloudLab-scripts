#!/bin/bash

# Set CPU scaling governor to "performance"
commands="sudo cpupower frequency-set -g performance;"
# Mount hugepages
commands+="sudo hugeadm --create-mounts;"

pdsh -w ^/shome/rc-hosts.txt -x rcnfs "$commands"
