#!/bin/bash
numhugepages=$(cat /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages)

sudo umount /dev/hugetlbfs > /dev/null 2>&1
sudo umount /dev/hugepages > /dev/null 2>&1
sudo mkdir -p /dev/hugepages
sudo chmod 777 /dev/hugepages
sudo mount -t hugetlbfs none /dev/hugepages -o pagesize=1G,size="$numhugepages"G
sudo chmod 777 /dev/hugepages
