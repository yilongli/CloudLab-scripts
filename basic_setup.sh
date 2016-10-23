#!bin/bash

# What is the difference between `sudo bash basic_setup.sh` and appending `sudo` in front of commands in this script?
# Install RAMCloud dependencies
apt-get update
apt-get --assume-yes install build-essential git-core doxygen libpcre3-dev protobuf-compiler libprotobuf-dev libcrypto++-dev libevent-dev libboost-all-dev libgtest-dev libzookeeper-mt-dev zookeeper libssl-dev openjdk-8-jdk

# Install other utilities
apt-get --assume-yes install vim tmux pdsh

# NFS
apt-get --assume-yes install nfs-kernel-server nfs-common

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
echo "ssh" > /etc/pdsh/rcmd_default
