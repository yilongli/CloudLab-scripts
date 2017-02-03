totkb=`cat /proc/meminfo | grep MemTotal | rev | cut -d ' ' -f2 | rev`
numhugepages=$(echo "($totkb/1024/1024)-8"|bc)
echo "hugepages:" $numhugepages
sudo sed -i.bak 's#^\(GRUB_CMDLINE_LINUX_DEFAULT="crashkernel=384M-:128M\)"$#\1 hugepagesz=1GB hugepages=' 8 '"#' /etc/default/grub
sudo update-grub
#sudo reboot
