#!/bin/bash

# Get RAMCloud
cd /shome
#git clone https://github.com/PlatformLab/RAMCloud.git
git clone https://github.com/yilongli/RAMCloud.git
cd RAMCloud
git submodule update --init --recursive
ln -s ../../hooks/pre-commit .git/hooks/pre-commit
cp /local/scripts/dpdkBuild.sh scripts/
cp /local/scripts/cluster.py scripts/
cp /local/scripts/common.py scripts/

# Generate scripts/localconfig.py
let num_rcXX=$(geni-get manifest | grep -o "<node " | wc -l)-2
python /local/scripts/localconfigGen.py ${num_rcXX} > scripts/localconfig.py

# NFS clients setup: use the publicly-routable IP addresses for both the server
# and the clients to avoid interference with the experiment.
rcnfs=$(hostname -i)
pdsh -R ssh -w ^/shome/rc-hosts.txt -x rcnfs \
    "sudo mkdir /shome; sudo mount -t nfs4 ${rcnfs}:/shome /shome;" \
    "NFS_CONFIG=\"${rcnfs}:/shome /shome nfs4 rw,sync,hard,intr," \
    "addr=\$(hostname -i) 0 0\"; echo \${NFS_CONFIG} | sudo tee -a /etc/fstab"

# Install GRUB and update GRUB configuration
# TODO: AVOID HARDCODING /shome/default-grub
#pdsh -R ssh -w ^/shome/rc-hosts.txt -x rcnfs \
#    "sudo grub-install /dev/nvme0n1; cat /shome/default-grub | sudo tee /etc/default/grub; sudo update-grub"

# TODO: CONFIGURE IRQ AFFINITY

# TODO: SCALING GOVERNOR
# https://github.com/epickrram/perf-workshop/blob/master/src/main/shell/set_cpu_governor.sh

# Install Mellanox OFED for rcmaster & rcXX. The cluster must be rebooted to
# work properly. Note: attempting to build MLNX DPDK before installing MLNX
# OFED may result in compile-time errors.
MLNX_OFED="MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu14.04-x86_64"
pdsh -R ssh -w ^/shome/rc-hosts.txt -x rcnfs \
    "sudo /shome/$MLNX_OFED/mlnxofedinstall --force --without-fw-update;" \
    "sudo reboot"
