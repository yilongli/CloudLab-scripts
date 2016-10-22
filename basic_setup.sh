# What is the difference between `sudo bash basic_setup.sh` and appending `sudo` in front of commands in this script?
# Install RAMCloud dependencies
apt-get update
apt-get --assume-yes install build-essential git-core doxygen libpcre3-dev protobuf-compiler libprotobuf-dev libcrypto++-dev libevent-dev libboost-all-dev libgtest-dev libzookeeper-mt-dev zookeeper libssl-dev openjdk-8-jdk

# Install other utilities
apt-get --assume-yes install vim pdsh

# NFS
apt-get --assume-yes install nfs-kernel-server nfs-common

# Setup password-less ssh between nodes
for user in `ls /users`; do
    if [ "$user" = "geniuser" ]; then
        continue
    fi

    ssh_dir=/users/$user/.ssh
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
