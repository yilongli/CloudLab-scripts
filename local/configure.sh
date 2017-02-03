#touch primary storage file
touch /local/ramcloud_primary
#touch secondary storage file
touch /local/ramcloud_secondary
#make local directory to share logs
mkdir -p /local/ramcloud_shared/
#mount the local share on nfs server at node-0
server=$(cat /local/node-0-ip.txt)
sudo mount $server:/local/ramcloud_logs /local/ramcloud_shared/
sudo chmod 777 -R /local/ramcloud_shared
mkdir -p /local/RAMCloud/logs/
#Change first backup to /local/ramcloud_primary
sed -i.bak "/default_disk1 \=/c\default_disk1 \= '-f \/local\/ramcloud_primary'" /local/RAMCloud/scripts/config.py
#Change default_disk_2 to sdc
sed -i.bak "/default_disk2 \=/c\default_disk2 \= '-f \/local\/ramcloud_secondary'" /local/RAMCloud/scripts/config.py
#Change softlocks on memory
#echo "* soft memlock unlimited" | sudo tee -a /etc/security/limits.conf
#Change hardlocks on memory
#echo "* hard memlock unlimited" | sudo tee -a /etc/security/limits.conf
#Copy the localconfig.py scripts
cp /local/localconfig.py /local/RAMCloud/scripts/localconfig.py
