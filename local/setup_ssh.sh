#/bin/sh
#echo "Changing tty requirements in sudoers"
#sudo sed -i.bak s/requiretty/\!requiretty/g /etc/sudoers
echo "setting up passwordless ssh between nodes"
user=`whoami`
if [[ "$user" == "root" ]]; then
    echo "doing for root"
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

else
    /usr/bin/geni-get key > /users/$user/.ssh/id_rsa
    chmod 600 /users/$user/.ssh/id_rsa
    ssh-keygen -y -f /users/$user/.ssh/id_rsa > /users/$user/.ssh/id_rsa.pub
    cat /users/$user/.ssh/id_rsa.pub >> /users/$user/.ssh/authorized_keys
    chmod 644 /users/$user/.ssh/authorized_keys
    cat >>/users/$user/.ssh/config <<EOL
    Host *
         StrictHostKeyChecking no
EOL
    chmod 644 /users/$user/.ssh/config
fi
