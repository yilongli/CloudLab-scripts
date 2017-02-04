#!/bin/bash

# Assuming Ubuntu 14.04

# Test if startup service has run before.
if [ -f /local/startup_service_done ]; then
    exit 0
fi
> /local/startup_service_done

# Install common utilities
apt-get update
apt-get --assume-yes install mosh vim tmux pdsh tree axel

# NFS
apt-get --assume-yes install nfs-kernel-server nfs-common

# Install RAMCloud dependencies
apt-get --assume-yes install build-essential git-core doxygen libpcre3-dev \
        protobuf-compiler libprotobuf-dev libcrypto++-dev libevent-dev \
        libboost-all-dev libgtest-dev libzookeeper-mt-dev zookeeper \
        libssl-dev default-jdk ccache

# Install numpy, scipy, matplotlib and docopt
apt-get --assume-yes install python-numpy python-scipy python-docopt \
        python-matplotlib

# TODO: need at least gcc 4.9.X to pass RAMCloud unit tests

# Setup password-less ssh between nodes
users="root `ls /users`"
for user in $users; do
    if [ "$user" = "root" ]; then
        ssh_dir=/root/.ssh
    else
        ssh_dir=/users/$user/.ssh
    fi
    /usr/bin/geni-get key > $ssh_dir/id_rsa
    chmod 600 $ssh_dir/id_rsa
    chown $user: $ssh_dir/id_rsa
    ssh-keygen -y -f $ssh_dir/id_rsa > $ssh_dir/id_rsa.pub
    cat $ssh_dir/id_rsa.pub >> $ssh_dir/authorized_keys
    chmod 644 $ssh_dir/authorized_keys
    cat >>$ssh_dir/config <<EOL
    Host *
         StrictHostKeyChecking no
EOL
    chmod 644 $ssh_dir/config
done

# Change user login shell to Bash
for user in `ls /users`; do
    chsh -s `which bash` $user
done

# Fix "rcmd: socket: Permission denied" when using pdsh
echo ssh > /etc/pdsh/rcmd_default

# Load 8021q module at boot time
echo 8021q >> /etc/modules

hostname=`hostname --short`
if [ "$hostname" = "rcnfs" ]; then
    # In `cloudlab-profile.py`, we already asked for a temporary file system
    # mounted at /shome.
    chmod 777 /shome
    echo "/shome *(rw,sync,no_root_squash)" >> /etc/exports

    # TODO: HOW TO START THE SERVICE AUTOMATICALLY AFTER REBOOT?
    /etc/init.d/nfs-kernel-server start

    # Get Mellanox OFED but do not install it during startup service
    cd /shome
    MLNX_OFED="MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu14.04-x86_64"
    axel -n 4 -q http://www.mellanox.com/downloads/ofed/MLNX_OFED-3.4-1.0.0.0/$MLNX_OFED.tgz; \
            tar xzf $MLNX_OFED.tgz &

    # Generate a list of machines in the cluster
    # TODO: USE IP ADDRESSES?
    > rc-hosts.txt
    num_nodes=$1
    for i in $(seq "$(($num_nodes-2))")
    do
        printf "rc%02d\n" $i >> rc-hosts.txt
    done
    printf "rcmaster\n" >> rc-hosts.txt
    printf "rcnfs\n" >> rc-hosts.txt
else
    # Enable hugepage support: http://dpdk.org/doc/guides/linux_gsg/sys_reqs.html
    # The changes will take effects after reboot.
    # m510 is not a NUMA machine.
    echo vm.nr_hugepages=1024 >> /etc/sysctl.conf
    mkdir /mnt/huge
    chmod 777 /mnt/huge
    echo "nodev /mnt/huge hugetlbfs defaults 0 0" >> /etc/fstab

    # Enable cpuset functionality if it's not been done yet.
    if [ ! -d "/sys/fs/cgroup/cpuset" ]; then
        mount -t tmpfs cgroup_root /sys/fs/cgroup
        mkdir /sys/fs/cgroup/cpuset
        mount -t cgroup cpuset -o cpuset /sys/fs/cgroup/cpuset/
    fi
fi

