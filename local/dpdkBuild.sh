#!/bin/bash

# Utility script that automates the process of fetching a stable dpdk release,
# configuring its compilation options, and building the dpdk libraries.

DPDK_VER="2.0.0"
#DPDK_VER="16.07"

if [ ! -d ./deps ]; then mkdir deps; fi

if [ ! -d ./deps/dpdk-${DPDK_VER} ];
then
	cd deps;
	wget --no-clobber http://dpdk.org/browse/dpdk/snapshot/dpdk-${DPDK_VER}.tar.gz
	tar zxvf dpdk-${DPDK_VER}.tar.gz
	cd ..
fi
ln -sfn deps/dpdk-${DPDK_VER} dpdk

# Configure the build process to produce a unified object archive file.
#sed -i s/CONFIG_RTE_BUILD_COMBINE_LIBS=n/CONFIG_RTE_BUILD_COMBINE_LIBS=y/ dpdk/config/common_linuxapp
#sed -i s/CONFIG_RTE_BUILD_SHARED_LIB=n/CONFIG_RTE_BUILD_SHARED_LIB=y/ dpdk/config/common_*

# Build the libraries, assuming an x86_64 linux target, and a gcc-based
# toolchain. Compile position-indepedent code, which will be linked by
# RAMCloud code.
cd dpdk && CPU_FLAGS="-fPIC" make -j12 install T=x86_64-native-linuxapp-gcc CONFIG_RTE_BUILD_SHARED_LIB=y CONFIG_RTE_BUILD_COMBINE_LIBS=y
