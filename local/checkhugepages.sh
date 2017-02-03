totkb=`cat /proc/meminfo | grep MemTotal | rev | cut -d ' ' -f2 | rev`
numhugepages=$(echo "$totkb/1024/1024/2"|bc)
echo "total pages should be "$numhugepages
sudo stat /sys/devices/system/node/node0/hugepages/hugepages-1048576kB/nr_hugepages > /dev/null || exit 1
nr=$(sudo cat /sys/devices/system/node/node0/hugepages/hugepages-1048576kB/nr_hugepages)
if [[ "$nr" == "$numhugepages" ]]; then
    exit 0
else
    exit 1
fi
