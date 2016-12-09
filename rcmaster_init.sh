#!/bin/bash
# TODO: HOW CAN WE START THIS SERVICE AT BOOT TIME
sudo /etc/init.d/nfs-kernel-server start

# NFS clients setup
pdsh -R ssh -w ^/shome/machines.txt \
    'sudo mkdir /shome; sudo mount rcmaster:/shome /shome;' \
    'echo "rcmaster:/shome /shome nfs rw,sync,hard,intr 0 0" | sudo tee -a /etc/fstab;'

# Install Mellanox OFED for the entire cluster (rcmaster & rcXX)
MLNX_OFED="MLNX_OFED_LINUX-3.1-1.0.3-ubuntu14.04-x86_64"
sudo /shome/$MLNX_OFED/mlnxofedinstall --force --without-fw-update &
pdsh -R ssh -w ^/shome/machines.txt \
    "sudo /shome/$MLNX_OFED/mlnxofedinstall --force --without-fw-update"

# TODO: enable hugepage support
