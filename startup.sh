#!bin/bash

# Assuming Ubuntu 14.04

# What is the difference between `sudo bash startup.sh` and appending `sudo` in front of commands in this script?
# Install RAMCloud dependencies
apt-get update
apt-get --assume-yes install build-essential git-core doxygen libpcre3-dev protobuf-compiler libprotobuf-dev libcrypto++-dev libevent-dev libboost-all-dev libgtest-dev libzookeeper-mt-dev zookeeper libssl-dev openjdk-8-jdk

# Install other utilities
apt-get --assume-yes install vim tmux pdsh tree

# NFS
apt-get --assume-yes install nfs-kernel-server nfs-common

# MLNX OFED & DPDK
# wget http://www.mellanox.com/downloads/ofed/MLNX_OFED-3.4-1.0.0.0/MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu14.04-x86_64.tgz
# tar xzf MLNX_OFED_LINUX-3.1-1.0.3-ubuntu14.04-x86_64.tgz
# MLNX_OFED_LINUX-3.1-1.0.3-ubuntu14.04-x86_64.tgz/mlnxofedinstall --force --without-fw-update
# wget http://www.mellanox.com/downloads/Drivers/MLNX_DPDK_2.2_4.2.tar.gz

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
# TODO: Generate cluster hosts list for pdsh?

# Load 8021q module
echo 8021q >> /etc/modules

# Setup NFS server and clients.
hostname=`hostname --short`
if [ "$hostname" = "rcmaster" ]; then
    /etc/init.d/nfs-kernel-server start
    mkdir /shome
    chmod 777 /shome
    echo "/shome *(rw,sync,no_root_squash)" >> /etc/exports
else
    mkdir /shome
    mount rcmaster:/shome /shome
    echo "rcmaster:/shome /shome nfs rw,sync,hard,intr 0 0" >> /etc/fstab
fi
