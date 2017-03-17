#!/bin/bash

# https://www.hiroom2.com/2016/07/14/ubuntu-16-04-debug-package-with-debug-symbol/
# https://superuser.com/questions/62575/where-is-vmlinux-on-my-ubuntu-installation

D=`lsb_release -cs`
sudo su -c "
cat <<EOF > /etc/apt/sources.list.d/ddebs.list
deb http://ddebs.ubuntu.com ${D} main restricted universe multiverse
deb http://ddebs.ubuntu.com ${D}-security main restricted universe multiverse
deb http://ddebs.ubuntu.com ${D}-updates main restricted universe multiverse
#deb http://ddebs.ubuntu.com ${D}-proposed main restricted universe multiverse
EOF
"
wget -O - http://ddebs.ubuntu.com/dbgsym-release-key.asc | sudo apt-key add -
sudo apt update -y

sudo apt-get install linux-image-$(uname -r)-dbgsym

cp /usr/lib/debug/boot/vmlinux-$(uname -r) /shome/
