#!/bin/bash
sudo /etc/init.d/nfs-kernel-server start
pdsh -R ssh -w ^/shome/machines.txt \
    'sudo mkdir /shome; sudo mount rcmaster:/shome /shome;' \
    'echo "rcmaster:/shome /shome nfs rw,sync,hard,intr 0 0" | sudo tee -a /etc/fstab;'
# TODO: enable hugepage support
