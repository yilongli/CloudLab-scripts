#!/bin/bash
sudo update-rc.d nfs-kernel-server enable
# TODO: FIX THIS
pdsh -R ssh -w ^/shome/machines.txt \
    'sudo mkdir /shome; sudo mount rcmaster:/shome /shome;' \
    'echo "rcmaster:/shome /shome nfs rw,sync,hard,intr 0 0" | sudo tee -a /etc/fstab;' \
    'sudo /shome/MLNX_OFED/mlnxofedinstall --force --without-fw-update'

