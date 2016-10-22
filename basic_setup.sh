# Install RAMCloud dependencies
apt-get update
apt-get --assume-yes install build-essential git-core doxygen libpcre3-dev protobuf-compiler libprotobuf-dev libcrypto++-dev libevent-dev libboost-all-dev libgtest-dev libzookeeper-mt-dev zookeeper libssl-dev openjdk-8-jdk

# Install other utilities
apt-get --assume-yes vim pdsh

# Setup password-less ssh between nodes
/usr/bin/geni-get key > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa
ssh-keygen -y -f /root/.ssh/id_rsa > /root/.ssh/id_rsa.pub
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
chmod 644 /root/.ssh/authorized_keys
cat >>/root/.ssh/config <<EOL
Host *
      StrictHostKeyChecking no
EOL
chmod 644 /root/.ssh/config
