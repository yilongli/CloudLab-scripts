#!/bin/bash
sudo rm -rf /local/RAMCloud
cd /local && git clone https://github.com/PlatformLab/RAMCloud.git
cd /local/RAMCloud && git submodule update --init --recursive
DPDK_VER="16.07"

if [ ! -d /local/RAMCloud/deps ]; then mkdir deps; fi

if [ ! -d /local/RAMCloud/deps/dpdk-${DPDK_VER} ];
then
        cd /local/RAMCloud/deps;
        wget http://dpdk.org/browse/dpdk/snapshot/dpdk-${DPDK_VER}.tar.gz
        tar zxvf dpdk-${DPDK_VER}.tar.gz
        cd ..
fi

# Configure the build process to produce a unified object archive file.

# Build the libraries, assuming an x86_64 linux target, and a gcc-based
# toolchain. Compile position-indepedent code, which will be linked by
# RAMCloud code.
cd /local/RAMCloud/deps/dpdk-${DPDK_VER} && make -j12 install T=x86_64-native-linuxapp-gcc
sed -i.bak "/CONFIG_RTE_BUILD_SHARED_LIB=n/c\CONFIG_RTE_BUILD_SHARED_LIB=y" /local/RAMCloud/deps/dpdk-${DPDK_VER}/x86_64-native-linuxapp-gcc/.config
sed -i.bak "/CONFIG_RTE_EAL_PMD_PATH=/c\CONFIG_RTE_EAL_PMD_PATH=\"/local/RAMCloud/deps/dpdk-${DPDK_VER}/x86_64-native-linuxapp-gcc/lib\"" /local/RAMCloud/deps/dpdk-${DPDK_VER}/x86_64-native-linuxapp-gcc/.config
cd /local/RAMCloud/deps/dpdk-${DPDK_VER}/x86_64-native-linuxapp-gcc && make clean
cd /local/RAMCloud/deps/dpdk-${DPDK_VER}/x86_64-native-linuxapp-gcc && make -j12
# libdpdk.so is a text file that will cause problems with plugin_init later
rm /local/RAMCloud/deps/dpdk-${DPDK_VER}/x86_64-native-linuxapp-gcc/lib/libdpdk.so
cd /local/RAMCloud && make -j12 DEBUG=no DPDK=yes DPDK_DIR=/local/RAMCloud/deps/dpdk-${DPDK_VER}
