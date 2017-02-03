#!/bin/bash

sudo mkdir -p /rc_primary
sudo mkdir -p /rc_secondary
sudo mkfs.ext3 -F /dev/sdb
sudo mount /dev/sdb /rc_primary
sudo mkfs.ext3 -F /dev/sdc
sudo mount /dev/sdc /rc_secondary
sudo chmod a+rw -R /dev/sdb
sudo chmod a+rw -R /dev/sdc
echo "Done"
