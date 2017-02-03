DPDK_VER=`basename /local/RAMCloud/deps/dpdk-*`
IF=`python /local/RAMCloud/deps/${DPDK_VER}/tools/dpdk-devbind.py --status | grep "10GbE" | grep "Active" | cut -d '=' -f2 | cut -d ' ' -f1`
PORT=`python /local/RAMCloud/deps/${DPDK_VER}/tools/dpdk-devbind.py --status | grep "10GbE" | grep "Active" | cut -d ':' -f1-3 | cut -d ' ' -f1`

echo "DPDK dir"${DPDK_VER}
sudo rmmod igb_uio
sudo modprobe uio
sudo insmod /local/RAMCloud/deps/${DPDK_VER}/x86_64-native-linuxapp-gcc/kmod/igb_uio.ko
for p in $PORT
do
  echo "Binding port:"$p "to DPDK"
  sudo su -c "echo $p | tee /sys/bus/pci/drivers/i40e/unbind"
  sudo python /local/RAMCloud/deps/${DPDK_VER}/tools/dpdk-devbind.py --bind=igb_uio $p
done
