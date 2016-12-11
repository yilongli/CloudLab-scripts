#!/bin/bash

# NFS clients setup
pdsh -R ssh -w ^/shome/machines.txt -x rcnfs \
    'sudo mkdir /shome; sudo mount rcnfs:/shome /shome;' \
    'echo "rcnfs:/shome /shome nfs rw,sync,hard,intr 0 0" | sudo tee -a /etc/fstab;'

# Install Mellanox OFED for rcmaster & rcXX. The cluster must be rebooted to
# work properly. Note: attempting to build MLNX DPDK before installing MLNX
# OFED may result in compile-time errors.
MLNX_OFED="MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu14.04-x86_64"
pdsh -R ssh -w ^/shome/machines.txt -x rcnfs \
    "sudo /shome/$MLNX_OFED/mlnxofedinstall --force --without-fw-update;" \
    "sudo reboot"

# Get RAMCloud
cd /shome
git clone https://github.com/PlatformLab/RAMCloud.git
cd RAMCloud
git submodule update --init --recursive
ln -s ../../hooks/pre-commit .git/hooks/pre-commit

# Generate scripts/localconfig.py
let num_rcXX=$(geni-get manifest | grep -o "<node " | wc -l)-2
cp /local/scripts/localconfig.template scripts/localconfig.py
sudo sed -i "s/#NUM_RCXX#/$num_rcXX/g" scripts/localconfig.py
