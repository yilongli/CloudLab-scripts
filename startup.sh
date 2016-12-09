#!/bin/bash

# Assuming Ubuntu 14.04

apt-get update
# Install common utilities
apt-get --assume-yes install vim tmux pdsh tree axel

# NFS
apt-get --assume-yes install nfs-kernel-server nfs-common

# Install RAMCloud dependencies
apt-get --assume-yes install build-essential git-core doxygen libpcre3-dev \
        protobuf-compiler libprotobuf-dev libcrypto++-dev libevent-dev \
        libboost-all-dev libgtest-dev libzookeeper-mt-dev zookeeper \
        libssl-dev openjdk-8-jdk

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

# NFS server setup
hostname=`hostname --short`
if [ "$hostname" = "rcmaster" ]; then
    mkdir /shome
    chmod 777 /shome
    echo "/shome *(rw,sync,no_root_squash)" >> /etc/exports
fi

# rcmaster-specific setup
if [ "$hostname" = "rcmaster" ]; then
    cd /shome

    # Get Mellanox OFED but do not install it during startup service
    MLNX_OFED="MLNX_OFED_LINUX-3.1-1.0.3-ubuntu14.04-x86_64"
    axel -n 4 -q http://www.mellanox.com/downloads/ofed/MLNX_OFED-3.1-1.0.3/$MLNX_OFED.tgz; \
            tar xzf $MLNX_OFED.tgz &

    # Generate a list of machines in the cluster
    let num_nodes=$1-1
    > machines.txt
    for i in $(seq "$num_nodes")
    do
        printf "rc%02d\n" $i >> machines.txt
    done

    # Get RAMCloud
    git clone https://github.com/PlatformLab/RAMCloud.git
    cd RAMCloud
    git submodule update --init --recursive
    ln -s ../../hooks/pre-commit .git/hooks/pre-commit
    scripts/dpdkBuild.sh

    # Mark the end of the startup service
    > DONE.txt
fi

