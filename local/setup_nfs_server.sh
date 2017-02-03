#Add shared log directory for nfs server
mkdir -p /local/ramcloud_logs
#Change ownership of the folder to nobody
sudo chown 65534:65534 /local/ramcloud_logs

#This assumes that you ran /local/generate_config.py before and has the files in place
sudo cp /local/exports /etc/exports
sudo cp /local/hosts.allow /etc/hosts.allow

#Reload exported entries
sudo exportfs -a
# Start the various services
sudo systemctl restart nfs-kernel-server.service
sleep 5
